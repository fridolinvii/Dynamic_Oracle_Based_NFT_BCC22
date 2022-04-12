import base64
import json
import sys

from PySide2 import QtCore, QtGui, QtWidgets
from PySide2.QtWebEngineWidgets import QWebEngineView

from brownie import *


class DisplaySVG(QtWidgets.QWidget):
    def __init__(self, parent=None, svg=""):
        super().__init__(parent)
        self.resize(450, 450)
        self.verticalLayout = QtWidgets.QVBoxLayout(self)
        self.webview = QWebEngineView(self)
        self.verticalLayout.addWidget(self.webview)

        self.setWindowTitle("Display SVG")
        act = QtWidgets.QAction("Close", self)
        act.setShortcuts([QtGui.QKeySequence(QtCore.Qt.Key_Escape)])
        act.triggered.connect(self.close)
        self.addAction(act)

        self.webview.setHtml(svg)


def data2svg(data):
    data = data.split(",")[1]
    b64_str = data.encode('ascii')
    url_bytes_b64 = base64.urlsafe_b64decode(b64_str)
    str_64 = str(url_bytes_b64, "utf-8")
    j = json.loads(str_64)
    r = j["image"]
    r = r.split(",")[1]
    b64_str = r.encode('ascii')
    url_bytes_b64 = base64.urlsafe_b64decode(b64_str)
    str_64 = str(url_bytes_b64, "utf-8")
    return str_64


def main():
    me = accounts[0]
    a1 = accounts[1]


    nk = NoahKatterbach.deploy({'from': me})
    ap = AndyPelmard.deploy({'from': me})
    pk = PajtimKasami.deploy({'from': me})
    lm = LiamMillar.deploy({'from': me})
    hl = HeinzLindner.deploy({'from': me})


    getSVG = getPlayerSvg.deploy(ap.address, lm.address, nk.address, pk.address, hl.address, {'from': me})

    c = SVG.deploy(getSVG.address, {'from': me})

    # add 4 players
    #addPlayer(string memory _playersName, string memory _position, uint _gameplay, uint _numberOfGames, uint _goals )
    c.addPlayer("Heinz Lindner","Goalkeeper",2489,26,0);
    c.addPlayer("Noah Katterbach","Defence",766,8,1);
    c.addPlayer("Andy Pelmard","Defence",2267,24,0);
    c.addPlayer("Pajtim Kasami","Midfield",1734,24,3);
    c.addPlayer("Liam Millar","Offense",1611,25,5);



    # mint the four players
    c.mintPlayer(0,me,1)
    c.mintPlayer(1,me,1)
    c.mintPlayer(2,me,1)
    c.mintPlayer(3,me,1)
    #
    c.mintPlayer(4,me,1)
    # c.mintPlayer(8,me,1)
    # c.mintPlayer(12,me,1)
    # c.mintPlayer(16,me,1)
    # c.mintPlayer(20,me,1)


    # upgrade player
    # print("Upgrade Players: Minting")
    # c.mintPlayer(12,a1,30)
    # print(c.balanceOf(a1,12))
    # print(c.balanceOf(a1,13))
    # print(c.balanceOf(a1,14))
    # print(c.balanceOf(a1,15))
    # print("Upgrade Players: Bronze")
    # print(c.n())
    # c.upgradePlayer("Liam Millar",0,10, {"from": a1})
    # print(c.balanceOf(a1,12))
    # print(c.balanceOf(a1,13))
    # print(c.balanceOf(a1,14))
    # print(c.balanceOf(a1,15))
    # print("Upgrade Players: Silver")
    # c.upgradePlayer("Liam Millar",1,3, {"from": a1})
    # print(c.balanceOf(a1,12))
    # print(c.balanceOf(a1,13))
    # print(c.balanceOf(a1,14))
    # print(c.balanceOf(a1,15))
    # print("Upgrade Players: Gold")
    # c.upgradePlayer("Liam Millar",2,1, {"from": a1} )
    # print(c.balanceOf(a1,12))
    # print(c.balanceOf(a1,13))
    # print(c.balanceOf(a1,14))
    # print(c.balanceOf(a1,15))


    # Render image, toggle color, then render image again
    html = data2svg(c.uri(0))
    html += data2svg(c.uri(4))
    html += data2svg(c.uri(8))
    html += data2svg(c.uri(12))
    html += data2svg(c.uri(16))


    # html += data2svg(c.uri(4+3))
    # html += data2svg(c.uri(8+3))
    # html += data2svg(c.uri(12+3))
    # html += data2svg(c.uri(16+3))


    html2 = data2svg(c.uri(4))
    c.updatePlayer("Noah Katterbach", 900,10,5,{'from': me})
    html2 += data2svg(c.uri(4))

    # Print the SVGs
    print(html)

    # Display the SVGs
    if not QtWidgets.QApplication.instance():
        app = QtWidgets.QApplication(sys.argv)
    else:
        app = QtWidgets.QApplication.instance()

    disp1 = DisplaySVG(svg=html)
    disp1.show()
    app.exec_()
    disp2 = DisplaySVG(svg=html2)
    disp2.show()
    app.exec_()
    #
    #
    #
    # html = data2svg(c.uri(0))
    # html += data2svg(c.uri(4))
    # html += data2svg(c.uri(8))
    # html += data2svg(c.uri(12))
    # html += data2svg(c.uri(16))
    # disp = DisplaySVG(svg=html)
    # disp.show()
    # app.exec_()
