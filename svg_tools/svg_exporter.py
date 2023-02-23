import sys
from svglib.svglib import svg2rlg, SvgRenderer
from reportlab.graphics import renderPDF, renderPM
from lxml import etree


import cairosvg



svg_code = '''<!-- Hello World -->
<svg width="500px" height="500px" xmlns="http://www.w3.org/2000/svg">
<rect x="10.000000" y="10.000000" width="100.000000" height="100.000000" style="fill:rgb(255,0,0,255);stroke:rgb(139,69,69,255);stroke-width:2.000000"/>
</svg>'''








class SvgFileImmitator:    
    def __init__(self, svg_code:str):
        self.svg_code = svg_code
    
    def read(self):
        return self.svg_code

    def write(self, code):
        self.svg_code = code
    

def svg2rlg_from_string(svg_code, resolve_entities=False):
    svg_root = load_svg_code(svg_code, resolve_entities=resolve_entities)
    if svg_root is None:
        return

    # convert to a RLG drawing
    svgRenderer = SvgRenderer("")
    drawing = svgRenderer.render(svg_root)

    return drawing




def load_svg_code(svg_code, resolve_entities=False):
    svg_code = '''<!-- Hello World -->
<svg width="500px" height="500px" xmlns="http://www.w3.org/2000/svg">
<rect x="10.000000" y="10.000000" width="100.000000" height="100.000000" style="fill:rgb(255,0,0,255);stroke:rgb(139,69,69,255);stroke-width:2.000000"/>
</svg>'''

    

    svg_immitated_file = SvgFileImmitator(svg_code)



    parser = etree.XMLParser(
        remove_comments=True, recover=True, resolve_entities=resolve_entities
    )
    try:
        doc = etree.parse(svg_immitated_file, parser=parser)
        svg_root = doc.getroot()
    except Exception as exc:
        print("Reee Failed to load input file! (%s)", exc)
    else:
        return svg_root
    



def convert_svg(svg_code:str, output_format:str="pdf"):

    

    svg_immitated_file = SvgFileImmitator(svg_code)
    
    drawing = svg2rlg_from_string(svg_code)


    print(drawing)


    #drawing = svg2rlg("test.svg")
    renderPDF.drawToFile(drawing, "file.pdf")
    renderPM.drawToFile(drawing, "file.png", fmt="PNG")


"""
    if not svg_code:
        return
    if not output_format in ["pdf", "png"]:
        return
    
    svg_immitated_file = SvgFileImmitator(svg_code)
    
    drawing = svg2rlg(svg_immitated_file)
    renderPDF.drawToString(drawing)
    renderPM.drawToFile(drawing, "file.png", fmt="PNG")"""



# argv [script_name, svg_code, output_format="pdf"]
if __name__ == "__main__":

    cairosvg.svg2pdf(bytestring=svg_code, write_to='file.pdf')


    #convert_svg("", "png")
    #print(sys.argv)
    #print("aaa")
    #print("bbb")
    #sys.exit(69)
