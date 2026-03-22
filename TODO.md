# muzi

### REPLACE NON-BLOCKING SOCKET ON TTY
- Poll

### FIXES
- [ ] song features not displaying in the artist -> album tab: Tyler, the creaotr -> Flower Boy
- [ ] next and prev should change playmode if paused or stopped
- [ ] replace split with tokenize
- [ ] deprecate "Time:" field
- [ ] browser handle no tags testing
- [ ] blocking connect - wait for std.Io 
- [ ] Fix apostrophe searching
- [ ] ESC bug

### REFACTOR
- [ ] clean up main.zig
- [ ] inc should not be in app.scroll_q
- [ ] input.zig
- [ ] state.zig
- [ ] mpdclient.zig
- [ ] display width caching

### Features
- [ ] hold to batch inputs - arrow seeking especially
- [ ] next strings in browser should be on press - somehow load next strings for browser
    - [ ] naive get on press
- [ ] loose search by file if no tags
- [ ] tweak algorithm
    - [ ] score is a ratio of the length? 
    - [ ] algorithm tweak, prioritize matches at the start of the string
- [ ] look into Kitty input protocol - is it necessary ? 
- [ ] key input configuration ?
- [ ] PLAYLIST MANIPULATION
