from pathlib import Path

path = Path('Library.lua')
source = path.read_text()

replacements = [
    (
        'local RepoFontBaseUrl = "https://raw.githubusercontent.com/Fyntra-Development/Forma/main/fonts/";',
        'local RepoFontBaseUrl = "https://raw.githubusercontent.com/Fyntra-Development/Forma/main/";'
    ),
    (
        '    Rubik = {\n        Ttf = "Rubik.ttf",\n        RepoPath = "fonts/Rubik.ttf",\n    },',
        '    Rubik = {\n        Ttf = "Rubik.ttf",\n        RepoPath = "fonts/Rubik.ttf",\n        Url = RepoFontBaseUrl .. "fonts/Rubik.ttf",\n    },'
    ),
    (
        "    Fonts[Name] = {\n        Ttf = CleanFileName;\n        RepoPath = 'fonts/' .. CleanFileName;\n    };",
        "    Fonts[Name] = {\n        Ttf = CleanFileName;\n        RepoPath = 'fonts/' .. CleanFileName;\n        Url = RepoFontBaseUrl .. 'fonts/' .. CleanFileName;\n    };"
    ),
    (
        '    if not Info or not GetCustomAsset or not writefile or not isfile then\n        return false;\n    end;',
        '    if not Info or not GetCustomAsset or not writefile then\n        return false;\n    end;'
    ),
    (
        "        local FontUrl = RepoFontBaseUrl .. RepoPath:match('([^/]+)$');\n\n        if not isfile(TtfPath) then\n            writefile(TtfPath, game:HttpGet(FontUrl));\n        end;",
        "        local FontUrl = Info.Url or (RepoFontBaseUrl .. RepoPath);\n\n        writefile(TtfPath, game:HttpGet(FontUrl));"
    ),
    (
        "function Library:SetFont(Name)\n    return Library:LoadFont(Name);\nend;\n\nfunction Library:TweenProperty",
        "function Library:SetFont(Name)\n    return Library:LoadFont(Name);\nend;\n\nLibrary:LoadFont('Rubik');\n\nfunction Library:TweenProperty"
    ),
]

for old, new in replacements:
    count = source.count(old)
    if count != 1:
        raise SystemExit(f'expected exactly one match, got {count}: {old[:100]!r}')
    source = source.replace(old, new, 1)

assert "Library:LoadFont('Rubik');" in source
assert 'Url = RepoFontBaseUrl .. "fonts/Rubik.ttf"' in source
assert 'writefile(TtfPath, game:HttpGet(FontUrl));' in source
assert 'if not isfile(TtfPath)' not in source

path.write_text(source)
