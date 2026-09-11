# -*- mode: python ; coding: utf-8 -*-
from PyInstaller.utils.hooks import collect_submodules

hiddenimports = (
    collect_submodules('flask')
    + collect_submodules('flask_sqlalchemy')
    + collect_submodules('flask_login')
    + collect_submodules('flask_wtf')
    + collect_submodules('wtforms')
    + collect_submodules('sqlalchemy')
    + collect_submodules('dotenv')
    + collect_submodules('sqlalchemy.dialects.mssql')
    + ['pyodbc']
)

datas = [
    ('templates', 'templates'),
    ('static', 'static'),
]

block_cipher = None

a = Analysis(
    ['app.py'],
    pathex=['.'],
    binaries=[],
    datas=datas,
    hiddenimports=hiddenimports,
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)
exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='IT_Help_Desk',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=False,
)
coll = COLLECT(
    exe,
    a.binaries,
    a.zipfiles,
    a.datas,
    strip=False,
    upx=True,
    name='IT_Help_Desk',
)
