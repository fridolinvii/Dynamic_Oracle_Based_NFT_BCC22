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



    # Setup the Smart Contract

    nk = NoahKatterbach.deploy({'from': me})
    ap = AndyPelmard.deploy({'from': me})
    pk = PajtimKasami.deploy({'from': me})
    lm = LiamMillar.deploy({'from': me})
    hl = HeinzLindner.deploy({'from': me})

    getSVG = getPlayerSvg.deploy(ap.address, lm.address, nk.address, pk.address, hl.address, {'from': me})

    c = SVG.deploy(getSVG.address, {'from': me})
    m = mintingProcess.deploy(2103,c.address, {'from': me});

    ## Include interface
    # raffle after 100min, update statistic after 10min
    # (vrf,keeper,oracle) = (false,false,false) -> Note: oracle = true will do nothing (oracle not implemented)
    i = Interface.deploy(m.address, c.address, False, False, False, 100, 10, {'from': me})
    # Give the contracts execution writhe on the needed contracts
    c.changeMintingProcess(m.address, i.address, {'from': me})
    m.changeInterfaceAddress(i.address, {'from': me});

    # print("this should fail")
    # m.buyPlayer_noVrf(me, 100, {'from': me});

    i.buyPlayer({'from': a1, 'amount':  '0.1 ether'})
    i.withDraw(me, {'from': me})


    print("Balance of minted Players")
    for j in range(5):
        print([c.balanceOf(a1,j*4),c.balanceOf(a1,j*4+1),c.balanceOf(a1,j*4+2),c.balanceOf(a1,j*4+3)])


    i.upgradeAllToMax({'from': a1})


    print("Balance of minted Players After upgrade")
    for j in range(5):
        print([c.balanceOf(a1,j*4),c.balanceOf(a1,j*4+1),c.balanceOf(a1,j*4+2),c.balanceOf(a1,j*4+3)])

    i.buyPlayer({'from': a1, 'amount':  '0.1 ether'})
    print("Balance of minted Players After upgrade")
    for j in range(5):
        print([c.balanceOf(a1,j*4),c.balanceOf(a1,j*4+1),c.balanceOf(a1,j*4+2),c.balanceOf(a1,j*4+3)])
    i.withDraw(me, {'from': me})
    i.upgradeAllToMax({'from': a1})

    print("Balance of minted Players After upgrade")
    for j in range(5):
        print([c.balanceOf(a1,j*4),c.balanceOf(a1,j*4+1),c.balanceOf(a1,j*4+2),c.balanceOf(a1,j*4+3)])



    ## RAFFLE

    # add additional players

    for j in range(1,10):
        i.buyPlayer({'from': a[j], 'amount':  '0.01 ether'})
        i.upgradeAllToMax({'from': a[j]})

    for j in range(1,5):
        i.buyPlayer({'from': a[j], 'amount':  '0.2 ether'})
        i.upgradeAllToMax({'from': a[j]})


    print("Withdraw ETH")
    i.withDraw(me, {'from': me})





    # simulate Keeper
    html2 = data2svg(c.uri(0))
    # updates player and end calls raffle
    for j in range(10):
        i.simulateKeeper({'from': me})
        html2 += data2svg(c.uri(0))
        # sleep 10 min
        chain.sleep(10*60)


    i.simulateKeeper({'from': me})


    nft_address = i.getAddresses({'from': me})
    # Winner NFT
    for j in range(len(nft_address)):
        if c.balanceOf(nft_address[j],1001):
            print("Place 1: "+nft_address[j])
        if c.balanceOf(nft_address[j],1002):
            print("Place 2: "+nft_address[j])
        if c.balanceOf(nft_address[j],1003):
            print("Place 3: "+nft_address[j])

    # Unique NFT
    print("--------------")
    for j in range(len(nft_address)):
        for k in range(10):
            if c.balanceOf(nft_address[j],2001+k):
                print("Unique: "+nft_address[j])
            if c.balanceOf(nft_address[j],10000001+k):
                print("Team: "+nft_address[j])
        print("--------------")

    # Player NFT






    ############################################################################
    ## Stop upgrading and minting ##

    # i.stopMinting({'from': me});
    # i.buyPlayer({'from': a1, 'amount':  '1 ether'})
    # i.stopUpgrading({'from': me});
    # i.upgradeAllToMax({'from': a1});


    ############################################################################



    print("END")

    # Show NFTs
    # html = data2svg(c.uri(0))
    # html += data2svg(c.uri(1))
    # html += data2svg(c.uri(2))
    # html += data2svg(c.uri(3))
    #
    # html += data2svg(c.uri(4))
    # html += data2svg(c.uri(5))
    # html += data2svg(c.uri(6))
    # html += data2svg(c.uri(7))
    #
    # html += data2svg(c.uri(8))
    # html += data2svg(c.uri(9))
    # html += data2svg(c.uri(10))
    # html += data2svg(c.uri(11))
    #
    # html += data2svg(c.uri(12))
    # html += data2svg(c.uri(13))
    # html += data2svg(c.uri(14))
    # html += data2svg(c.uri(15))
    #
    # html += data2svg(c.uri(16))
    # html += data2svg(c.uri(17))
    # html += data2svg(c.uri(18))
    # html += data2svg(c.uri(19))



    # Winner NFT
    html = data2svg(c.uri(1001))
    html += data2svg(c.uri(1002))
    html += data2svg(c.uri(1003))

    # Unique NFT
    # html = data2svg(c.uri(2001))
    # html += data2svg(c.uri(2002))
    html += data2svg(c.uri(2003))
    #
    #

    # Team NFT
    #html = data2svg(c.uri(10000001))
    # html += data2svg(c.uri(10000002))
    html += data2svg(c.uri(10000003))
    # print(html)

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


    return i , c
