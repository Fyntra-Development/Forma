from pathlib import Path
p = Path('Library.lua')
s = p.read_text()

start = s.index('    local function ApplyProviderInfo(Info)')
end = s.index('    function HUD:SetInfo(Info)', start)
new = r'''    local function ApplyProviderInfo(Info)
        local Entries = {};

        local function Queue(Name, Value)
            table.insert(Entries, { Name or '', Value });
        end

        if type(Info) == 'string' or type(Info) == 'number' then
            Queue('', Info);
        elseif type(Info) == 'table' then
            if #Info > 0 then
                for _, Entry in ipairs(Info) do
                    if type(Entry) == 'table' then
                        Queue(Entry[1] or Entry.Name or Entry.Label or '', Entry[2] or Entry.Value or '');
                    else
                        Queue('', Entry);
                    end
                end
            else
                local Keys = {};
                for Key in next, Info do table.insert(Keys, Key); end
                table.sort(Keys, function(A, B) return tostring(A) < tostring(B); end);
                for _, Key in ipairs(Keys) do Queue(Key, Info[Key]); end
            end
        end

        for Index, Entry in ipairs(Entries) do
            local Id = '__provider_' .. tostring(Index);
            if not table.find(HUD.ProviderLabelIds, Id) then table.insert(HUD.ProviderLabelIds, Id); end
            CreateLabelHandle(Id, Entry[1], Entry[2], true);
        end

        for Index = #HUD.ProviderLabelIds, #Entries + 1, -1 do
            local Id = HUD.ProviderLabelIds[Index];
            HUD:RemoveLabel(Id);
        end
        UpdateLayout();
    end

'''
s = s[:start] + new + s[end:]

old = """        if not Instant and math.abs(Ratio - HUD.HealthTargetRatio) <= 0.0001 then return; end
"""
new = """        if not Instant and math.abs(Ratio - HUD.HealthTargetRatio) <= 0.0001 then
            UpdateHealthVisual();
            return;
        end
"""
if old not in s:
    raise SystemExit('health ratio guard missing')
s = s.replace(old, new, 1)
p.write_text(s)
