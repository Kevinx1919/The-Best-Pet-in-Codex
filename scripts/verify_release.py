"""Verify the published artifact; this does not replace Pets visual QA."""
from pathlib import Path
import hashlib
import json
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]
folder = ROOT / 'pets' / 'camo'
release = json.loads((folder / 'release.json').read_text(encoding='utf-8'))
manifest = json.loads((folder / 'pet.json').read_text(encoding='utf-8'))
atlas_path = folder / manifest['spritesheetPath']
assert atlas_path.resolve().parent == folder.resolve(), 'Sprite path escapes the package'
assert hashlib.sha256(atlas_path.read_bytes()).hexdigest() == release['sha256'], 'SHA-256 mismatch'
assert manifest['spriteVersionNumber'] == 2
with Image.open(atlas_path) as opened:
    assert opened.size == (1536, 2288) and opened.mode == 'RGBA'
    for row, count in enumerate(release['frames_per_row']):
        for col in range(8):
            cell = opened.crop((col * 192, row * 208, (col + 1) * 192, (row + 1) * 208))
            occupied = cell.getchannel('A').getbbox() is not None
            assert occupied == (col < count), f'Wrong occupancy at row {row}, column {col}'
    assert opened.getchannel('A').getextrema()[0] == 0
print('OK: SHA-256, v2 geometry, 73 occupied cells and 15 transparent unused cells.')
