from pathlib import Path

path = Path('Library.lua')
text = path.read_text()

needle = """    local MainTabIndicator = Library:CreateSlidingTabIndicator(TabIndicatorLayer, 21);\n\n    local TabContainer = Library:Create('Frame', {\n"""
replacement = """    local MainTabIndicator = Library:CreateSlidingTabIndicator(TabIndicatorLayer, 21);\n\n    TabListLayout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function()\n        if Window.ActiveTab and Window.ActiveTab.Button then\n            task.defer(function()\n                if Window.ActiveTab and Window.ActiveTab.Button then\n                    MainTabIndicator:Refresh(Window.ActiveTab.Button);\n                end;\n            end);\n        end;\n    end);\n\n    local TabContainer = Library:Create('Frame', {\n"""
assert text.count(needle) == 1, 'main indicator layout callback anchor mismatch'
text = text.replace(needle, replacement, 1)

needle = """        Tab.Active = false;\n        Tab.ContentAnimationId = 0;\n\n        local TabFrame = Library:Create('CanvasGroup', {\n"""
replacement = """        Tab.Active = false;\n        Tab.ContentAnimationId = 0;\n        Tab.Button = TabButton;\n\n        local TabFrame = Library:Create('CanvasGroup', {\n"""
assert text.count(needle) == 1, 'main Tab.Button anchor mismatch'
text = text.replace(needle, replacement, 1)

old_resize = """                function Tab:Resize()\n                    local TabCount = 0;\n\n                    for _, Tab in next, Tabbox.Tabs do\n                        TabCount = TabCount + 1;\n                    end;\n\n                    for _, Button in next, TabboxButtons:GetChildren() do\n                        if not Button:IsA('UIListLayout') then\n                            Button.Size = UDim2.new(1 / TabCount, 0, 1, 0);\n                        end;\n                    end;\n\n                    if (not Container.Visible) then\n                        return;\n                    end;\n"""
new_resize = """                function Tab:Resize()\n                    local TabCount = 0;\n\n                    for _, Child in next, TabboxButtons:GetChildren() do\n                        if not Child:IsA('UIListLayout') then\n                            TabCount = TabCount + 1;\n                        end;\n                    end;\n\n                    if TabCount <= 0 then\n                        return;\n                    end;\n\n                    for _, TabButtonObject in next, TabboxButtons:GetChildren() do\n                        if not TabButtonObject:IsA('UIListLayout') then\n                            TabButtonObject.Size = UDim2.new(1 / TabCount, 0, 1, 0);\n                        end;\n                    end;\n\n                    task.defer(function()\n                        for _, ExistingTab in next, Tabbox.Tabs do\n                            if ExistingTab.Active and ExistingTab.Button then\n                                TabboxIndicator:Refresh(ExistingTab.Button);\n                                break;\n                            end;\n                        end;\n                    end);\n\n                    if (not Container.Visible) then\n                        return;\n                    end;\n"""
assert text.count(old_resize) == 1, 'tabbox Resize block mismatch'
text = text.replace(old_resize, new_resize, 1)

needle = """                Tab.Container = Container;\n                Tabbox.Tabs[Name] = Tab;\n"""
replacement = """                Tab.Container = Container;\n                Tab.Button = Button;\n                Tabbox.Tabs[Name] = Tab;\n"""
assert text.count(needle) == 1, 'tabbox Tab.Button anchor mismatch'
text = text.replace(needle, replacement, 1)

assert "Window.ActiveTab.Button" in text
assert "Tab.Button = TabButton" in text
assert "Tab.Button = Button" in text
assert "for _, Child in next, TabboxButtons:GetChildren()" in text

path.write_text(text)
