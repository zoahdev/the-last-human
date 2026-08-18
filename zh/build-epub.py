# -*- coding: utf-8 -*-
"""Build a WeRead-friendly EPUB from zh/volume-* markdown files."""
import html, os, re, sys, zipfile

ROOT = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(os.path.dirname(ROOT), '..', '..', 'outputs', 'The-Last-Human-zh.epub')
OUT = os.path.abspath(OUT)

def md_inline(text):
    text = html.escape(text)
    text = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', text)
    text = re.sub(r'\*(.+?)\*', r'<em>\1</em>', text)
    return text

def md_to_xhtml(md_text):
    out = []
    in_list = False
    for line in md_text.splitlines():
        if not line.strip():
            if in_list:
                out.append('</ul>')
                in_list = False
            continue
        if line.startswith('### '):
            if in_list: out.append('</ul>'); in_list = False
            out.append('<h3>' + md_inline(line[4:]) + '</h3>')
        elif line.startswith('## '):
            if in_list: out.append('</ul>'); in_list = False
            out.append('<h2>' + md_inline(line[3:]) + '</h2>')
        elif line.startswith('# '):
            if in_list: out.append('</ul>'); in_list = False
            out.append('<h1>' + md_inline(line[2:]) + '</h1>')
        elif line.startswith('> '):
            if in_list: out.append('</ul>'); in_list = False
            out.append('<blockquote><p>' + md_inline(line[2:]) + '</p></blockquote>')
        elif line.strip() == '---':
            if in_list: out.append('</ul>'); in_list = False
            out.append('<hr/>')
        elif re.match(r'^\s*[-*] ', line):
            if not in_list:
                out.append('<ul>')
                in_list = True
            out.append('<li>' + md_inline(re.sub(r'^\s*[-*] ', '', line)) + '</li>')
        else:
            if in_list: out.append('</ul>'); in_list = False
            out.append('<p>' + md_inline(line) + '</p>')
    if in_list:
        out.append('</ul>')
    return '\n'.join(out)

def collect_chapters():
    chapters = []
    vols = sorted([d for d in os.listdir(ROOT) if d.startswith('volume-')],
                  key=lambda n: int(n.split('-')[1]))
    for v in vols:
        vdir = os.path.join(ROOT, v)
        vol_title = re.sub(r'^volume-\d+-', '', v).replace('-', ' ')
        files = sorted(f for f in os.listdir(vdir) if f.endswith('.md'))
        for f in files:
            with open(os.path.join(vdir, f), encoding='utf-8') as fh:
                text = fh.read()
            first = ''
            m = re.search(r'^#\s+(.+)$', text, re.M)
            if m:
                first = m.group(1).strip()
            chapters.append((vol_title, f, first, text))
    return chapters

chapters = collect_chapters()
os.makedirs(os.path.dirname(OUT), exist_ok=True)

xhtml_head = ('<?xml version="1.0" encoding="utf-8"?>\n'
              '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" '
              '"http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">\n'
              '<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="zh-CN">\n'
              '<head><title>{title}</title>'
              '<link rel="stylesheet" type="text/css" href="style.css"/></head>\n<body>\n')

nav_items = []
manifest = []
spine = []
for i, (vol, fname, first, text) in enumerate(chapters, 1):
    chap_id = 'chap%04d' % i
    body = md_to_xhtml(text)
    title = first or vol
    xh = xhtml_head.format(title=html.escape(title)) + body + '\n</body>\n</html>'
    with open(os.path.join(ROOT, chap_id + '.xhtml'), 'w', encoding='utf-8') as fh:
        fh.write(xh)
    nav_items.append((vol, title, chap_id + '.xhtml'))
    manifest.append((chap_id, chap_id + '.xhtml'))
    spine.append(chap_id)

# nav.xhtml
nav_parts = ['<?xml version="1.0" encoding="utf-8"?>',
             '<html xmlns="http://www.w3.org/1999/xhtml" xmlns:epub="http://www.idpf.org/2007/ops" xml:lang="zh-CN">',
             '<head><title>目录</title></head><body><nav epub:type="toc"><h1>目录</h1><ol>']
for vol, title, href in nav_items:
    nav_parts.append('<li><a href="%s">%s</a></li>' % (html.escape(href), html.escape(vol + ' · ' + title)))
nav_parts.append('</ol></nav></body></html>')
with open(os.path.join(ROOT, 'nav.xhtml'), 'w', encoding='utf-8') as fh:
    fh.write('\n'.join(nav_parts))

# content.opf
manifest_lines = ['<item id="nav" href="nav.xhtml" media-type="application/xhtml+xml" properties="nav"/>',
                  '<item id="css" href="style.css" media-type="text/css"/>']
for cid, href in manifest:
    manifest_lines.append('<item id="%s" href="%s" media-type="application/xhtml+xml"/>' % (cid, href))
spine_lines = ['<itemref idref="%s"/>' % cid for cid in spine]
opf = ('<?xml version="1.0" encoding="utf-8"?>\n'
       '<package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="uid" xml:lang="zh-CN">\n'
       '<metadata xmlns:dc="http://purl.org/dc/elements/1.1/">\n'
       '<dc:identifier id="uid">urn:uuid:last-human-zh-001</dc:identifier>\n'
       '<dc:title>最后的人类</dc:title>\n'
       '<dc:creator>作者（The Author）</dc:creator>\n'
       '<dc:language>zh-CN</dc:language>\n'
       '<meta property="dcterms:modified">2026-08-19T00:00:00Z</meta>\n'
       '</metadata>\n'
       '<manifest>\n' + '\n'.join(manifest_lines) + '\n</manifest>\n'
       '<spine>\n' + '\n'.join(spine_lines) + '\n</spine>\n'
       '</package>\n')
with open(os.path.join(ROOT, 'content.opf'), 'w', encoding='utf-8') as fh:
    fh.write(opf)

css = ('body { font-family: serif; line-height: 1.8; margin: 5% 6%; }\n'
       'h1 { text-align: center; }\nh2 { margin-top: 1.6em; }\n'
       'p { text-indent: 2em; margin: 0.4em 0; }\n'
       'blockquote { margin: 1em 2em; color: #333; }\n')
with open(os.path.join(ROOT, 'style.css'), 'w', encoding='utf-8') as fh:
    fh.write(css)

with open(os.path.join(ROOT, 'mimetype'), 'w') as fh:
    fh.write('application/epub+zip')
container = '<?xml version="1.0" encoding="utf-8"?>\n<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container"><rootfiles><rootfile full-path="OEBPS/content.opf" media-type="application/oebps-package+xml"/></rootfiles></container>\n'
os.makedirs(os.path.join(ROOT, 'META-INF'), exist_ok=True)
with open(os.path.join(ROOT, 'META-INF', 'container.xml'), 'w', encoding='utf-8') as fh:
    fh.write(container)

with zipfile.ZipFile(OUT, 'w', zipfile.ZIP_DEFLATED) as z:
    z.writestr('mimetype', 'application/epub+zip', compress_type=zipfile.ZIP_STORED)
    z.write(os.path.join(ROOT, 'META-INF', 'container.xml'), 'META-INF/container.xml')
    z.write(os.path.join(ROOT, 'content.opf'), 'OEBPS/content.opf')
    z.write(os.path.join(ROOT, 'nav.xhtml'), 'OEBPS/nav.xhtml')
    z.write(os.path.join(ROOT, 'style.css'), 'OEBPS/style.css')
    for cid, href in manifest:
        z.write(os.path.join(ROOT, href), 'OEBPS/' + href)
print('EPUB written: %s (%d chapters)' % (OUT, len(chapters)))

# cleanup intermediates
import glob as _glob
for _pat in ('chap*.xhtml', 'nav.xhtml', 'content.opf', 'style.css', 'mimetype'):
    for _f in _glob.glob(os.path.join(ROOT, _pat)):
        os.remove(_f)
import shutil as _shutil
_meta = os.path.join(ROOT, 'META-INF')
if os.path.isdir(_meta):
    _shutil.rmtree(_meta)
