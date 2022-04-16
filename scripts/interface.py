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



    ##  Include random minting process

    # print("this should work")
    # c.mintPlayer(0,me,10,{'from': me})

    m = mintingProcess.deploy(2103,c.address, {'from': me});


    ## Include interface
    i = Interface.deploy(m.address, c.address, False, {'from': me})
    # give m access to c
    c.changeMintingProcess(m.address, i.address, {'from': me})
    m.changeInterfaceAddress(i.address, {'from': me});

    # print("this should fail")
    # m.buyPlayer_noVrf(me, 100, {'from': me});

    i.buyPlayer({'from': a1, 'amount':  '1 ether'})
    i.withDraw(me, {'from': me})


    print("Balance of minted Players")
    for j in range(5):
        print([c.balanceOf(a1,j*4),c.balanceOf(a1,j*4+1),c.balanceOf(a1,j*4+2),c.balanceOf(a1,j*4+3)])


    i.upgradeAllToMax({'from': a1})


    print("Balance of minted Players After upgrade")
    for j in range(5):
        print([c.balanceOf(a1,j*4),c.balanceOf(a1,j*4+1),c.balanceOf(a1,j*4+2),c.balanceOf(a1,j*4+3)])

    i.buyPlayer({'from': a1, 'amount':  '1 ether'})
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
        i.buyPlayer({'from': a[j], 'amount':  '0.1 ether'})
        i.upgradeAllToMax({'from': a[j]})

    for j in range(1,5):
        i.buyPlayer({'from': a[j], 'amount':  '2 ether'})
        i.upgradeAllToMax({'from': a[j]})


    print("Withdraw ETH")
    i.withDraw(me, {'from': me})





    #print(nft_address)
    #print([a1,a[2],a[3],a[4]])

    print("createDistributionForRaffel")
    i.createDistributionForRaffel();
    print("nft_address")
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

    return i , c
