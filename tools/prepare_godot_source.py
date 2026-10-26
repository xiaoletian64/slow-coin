"""Small source compatibility fix for newer libc++ module visibility."""
from pathlib import Path
import sys
root = Path(sys.argv[1])
p = root / 'drivers/apple_embedded/os_apple_embedded.mm'
text = p.read_text()
# Godot 4.6.3 uses std::size(array); newer Apple libc++ no longer exposes it
# transitively through another header. Include its standard defining header.
if '#include <iterator>' not in text:
    p.write_text('#include <iterator>\n' + text)
print('Godot std::size header visibility prepared')
