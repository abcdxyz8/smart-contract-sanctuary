// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./core/ChainRunnersTypes.sol";
import "./ChainRunnersBaseRenderer.sol";
import "hardhat/console.sol";

contract AntiRunnersBaseRenderer is Ownable, ReentrancyGuard {
    ChainRunnersBaseRenderer public chainRunnersBaseRenderer;

    uint256 public constant NUM_LAYERS = 13;
    uint256 public constant NUM_COLORS = 8;

    uint16[][NUM_LAYERS][3] WEIGHTS;

    constructor(address _chainRunnersBaseRendererAddress) {
        chainRunnersBaseRenderer = ChainRunnersBaseRenderer(_chainRunnersBaseRendererAddress);

        // Default
        WEIGHTS[0][0] = [36, 225, 225, 225, 360, 135, 27, 360, 315, 315, 315, 315, 225, 180, 225, 180, 360, 180, 45, 360, 360, 360, 27, 36, 360, 45, 180, 360, 225, 360, 225, 225, 360, 180, 45, 360, 18, 225, 225, 225, 225, 180, 225, 361];
        WEIGHTS[0][1] = [875, 1269, 779, 779, 779, 779, 779, 779, 779, 779, 779, 779, 17, 8, 41];
        WEIGHTS[0][2] = [303, 303, 303, 303, 151, 30, 0, 0, 151, 151, 151, 151, 30, 303, 151, 30, 303, 303, 303, 303, 303, 303, 30, 151, 303, 303, 303, 303, 303, 303, 303, 303, 3066];
        WEIGHTS[0][3] = [645, 0, 1290, 322, 645, 645, 645, 967, 322, 967, 645, 967, 967, 973];
        WEIGHTS[0][4] = [0, 0, 0, 1250, 1250, 1250, 1250, 1250, 1250, 1250, 1250];
        WEIGHTS[0][5] = [121, 121, 121, 121, 121, 121, 243, 0, 0, 0, 0, 121, 121, 243, 121, 121, 243, 121, 121, 121, 121, 121, 243, 121, 121, 121, 121, 243, 121, 121, 121, 121, 243, 121, 121, 121, 243, 121, 121, 121, 121, 243, 121, 121, 121, 121, 243, 121, 121, 121, 121, 243, 121, 121, 121, 121, 243, 121, 121, 121, 121, 243, 121, 121, 243, 0, 0, 0, 121, 121, 243, 121, 121, 306];
        WEIGHTS[0][6] = [925, 555, 185, 555, 925, 925, 185, 1296, 1296, 1296, 1857];
        WEIGHTS[0][7] = [88, 88, 88, 88, 88, 265, 442, 8853];
        WEIGHTS[0][8] = [189, 189, 47, 18, 9, 28, 37, 9483];
        WEIGHTS[0][9] = [340, 340, 340, 340, 340, 340, 34, 340, 340, 340, 340, 170, 170, 170, 102, 238, 238, 238, 272, 340, 340, 340, 272, 238, 238, 238, 238, 170, 34, 340, 340, 136, 340, 340, 340, 340, 344];
        WEIGHTS[0][10] = [159, 212, 106, 53, 26, 159, 53, 265, 53, 212, 159, 265, 53, 265, 265, 212, 53, 159, 239, 53, 106, 5, 106, 53, 212, 212, 106, 159, 212, 265, 212, 265, 5066];
        WEIGHTS[0][11] = [139, 278, 278, 250, 250, 194, 222, 278, 278, 194, 222, 83, 222, 278, 139, 139, 27, 278, 278, 278, 278, 27, 278, 139, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 27, 139, 139, 139, 139, 0, 278, 194, 83, 83, 278, 83, 27, 306];
        WEIGHTS[0][12] = [981, 2945, 654, 16, 981, 327, 654, 163, 3279];

        // Skull
        WEIGHTS[1][0] = [36, 225, 225, 225, 360, 135, 27, 360, 315, 315, 315, 315, 225, 180, 225, 180, 360, 180, 45, 360, 360, 360, 27, 36, 360, 45, 180, 360, 225, 360, 225, 225, 360, 180, 45, 360, 18, 225, 225, 225, 225, 180, 225, 361];
        WEIGHTS[1][1] = [875, 1269, 779, 779, 779, 779, 779, 779, 779, 779, 779, 779, 17, 8, 41];
        WEIGHTS[1][2] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10000];
        WEIGHTS[1][3] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        WEIGHTS[1][4] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        WEIGHTS[1][5] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 384, 7692, 1923, 0, 0, 0, 0, 0, 1];
        WEIGHTS[1][6] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10000];
        WEIGHTS[1][7] = [0, 0, 0, 0, 0, 909, 0, 9091];
        WEIGHTS[1][8] = [0, 0, 0, 0, 0, 0, 0, 10000];
        WEIGHTS[1][9] = [526, 526, 526, 0, 0, 0, 0, 0, 526, 0, 0, 0, 526, 0, 526, 0, 0, 0, 526, 526, 526, 526, 526, 526, 526, 526, 526, 526, 526, 0, 0, 526, 0, 0, 0, 0, 532];
        WEIGHTS[1][10] = [80, 0, 400, 240, 80, 0, 240, 0, 0, 80, 80, 80, 0, 0, 0, 0, 80, 80, 0, 0, 80, 80, 0, 80, 80, 80, 80, 80, 0, 0, 0, 0, 8000];
        WEIGHTS[1][11] = [289, 0, 0, 0, 0, 404, 462, 578, 578, 0, 462, 173, 462, 578, 0, 0, 57, 0, 57, 0, 57, 57, 578, 289, 578, 57, 0, 57, 57, 57, 578, 578, 0, 0, 0, 0, 0, 0, 57, 289, 578, 0, 0, 0, 231, 57, 0, 0, 1745];
        WEIGHTS[1][12] = [714, 714, 714, 0, 714, 0, 0, 0, 7144];

        // Bot
        WEIGHTS[2][0] = [36, 225, 225, 225, 360, 135, 27, 360, 315, 315, 315, 315, 225, 180, 225, 180, 360, 180, 45, 360, 360, 360, 27, 36, 360, 45, 180, 360, 225, 360, 225, 225, 360, 180, 45, 360, 18, 225, 225, 225, 225, 180, 225, 361];
        WEIGHTS[2][1] = [875, 1269, 779, 779, 779, 779, 779, 779, 779, 779, 779, 779, 17, 8, 41];
        WEIGHTS[2][2] = [303, 303, 303, 303, 151, 30, 0, 0, 151, 151, 151, 151, 30, 303, 151, 30, 303, 303, 303, 303, 303, 303, 30, 151, 303, 303, 303, 303, 303, 303, 303, 303, 3066];
        WEIGHTS[2][3] = [645, 0, 1290, 322, 645, 645, 645, 967, 322, 967, 645, 967, 967, 973];
        WEIGHTS[2][4] = [2500, 2500, 2500, 0, 0, 0, 0, 0, 0, 2500, 0];
        WEIGHTS[2][5] = [0, 0, 0, 0, 0, 0, 588, 588, 588, 588, 588, 0, 0, 588, 0, 0, 588, 0, 0, 0, 0, 0, 588, 0, 0, 0, 0, 588, 0, 0, 0, 588, 588, 0, 0, 0, 588, 0, 0, 0, 0, 588, 0, 0, 0, 0, 0, 0, 0, 0, 0, 588, 0, 0, 0, 0, 588, 0, 0, 0, 0, 588, 0, 0, 0, 0, 0, 0, 0, 0, 588, 0, 0, 4];
        WEIGHTS[2][6] = [925, 555, 185, 555, 925, 925, 185, 1296, 1296, 1296, 1857];
        WEIGHTS[2][7] = [88, 88, 88, 88, 88, 265, 442, 8853];
        WEIGHTS[2][8] = [183, 274, 274, 18, 18, 27, 36, 9170];
        WEIGHTS[2][9] = [340, 340, 340, 340, 340, 340, 34, 340, 340, 340, 340, 170, 170, 170, 102, 238, 238, 238, 272, 340, 340, 340, 272, 238, 238, 238, 238, 170, 34, 340, 340, 136, 340, 340, 340, 340, 344];
        WEIGHTS[2][10] = [217, 362, 217, 144, 72, 289, 144, 362, 72, 289, 217, 362, 72, 362, 362, 289, 0, 217, 0, 72, 144, 7, 217, 72, 217, 217, 289, 217, 289, 362, 217, 362, 3269];
        WEIGHTS[2][11] = [139, 278, 278, 250, 250, 194, 222, 278, 278, 194, 222, 83, 222, 278, 139, 139, 27, 278, 278, 278, 278, 27, 278, 139, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 27, 139, 139, 139, 139, 0, 278, 194, 83, 83, 278, 83, 27, 306];
        WEIGHTS[2][12] = [981, 2945, 654, 16, 981, 327, 654, 163, 3279];
    }

    function tokenURI(
        uint256 tokenId,
        uint256 dna
    ) public view returns (string memory) {
        (
            ChainRunnersBaseRenderer.Layer[NUM_LAYERS] memory tokenLayers,
            ChainRunnersBaseRenderer.Color[NUM_COLORS][NUM_LAYERS] memory tokenPalettes,
            uint8 numTokenLayers,
            string[NUM_LAYERS] memory traitTypes
        ) = getTokenData(dna);

        string memory attributes;
        for (uint8 i = 0; i < numTokenLayers; i++) {
            attributes = string(
                abi.encodePacked(
                    attributes,
                    bytes(attributes).length == 0 ? "eyAg" : "LCB7",
                    "InRyYWl0X3R5cGUiOiAi",
                    traitTypes[i],
                    "IiwidmFsdWUiOiAi",
                    tokenLayers[i].name,
                    "IiB9"
                )
            );
        }
        string[4] memory svgBuffers = tokenSVGBuffer(
            tokenLayers,
            tokenPalettes,
            numTokenLayers
        );
        return
            string(
                abi.encodePacked(
                    "data:application/json;base64,eyAgImltYWdlX2RhdGEiOiAiPHN2ZyB2ZXJzaW9uPScxLjEnIHZpZXdCb3g9JzAgMCAzMjAgMzIwJyB4bWxucz0naHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmcnIHNoYXBlLXJlbmRlcmluZz0nY3Jpc3BFZGdlcyc+",
                    svgBuffers[0],
                    svgBuffers[1],
                    svgBuffers[2],
                    svgBuffers[3],
                    "PHN0eWxlPnJlY3R7d2lkdGg6MTBweDtoZWlnaHQ6MTBweDt9PC9zdHlsZT48L3N2Zz4gIiwgImF0dHJpYnV0ZXMiOiBb",
                    attributes,
                    "XSwgICAibmFtZSI6IlJ1bm5lciAj",
                    Base64.encode(uintToByteString(tokenId, 6)),
                    "IiwgImRlc2NyaXB0aW9uIjogIkNoYWluIFJ1bm5lcnMgYXJlIE1lZ2EgQ2l0eSByZW5lZ2FkZXMgMTAwJSBnZW5lcmF0ZWQgb24gY2hhaW4uIn0g"
                )
            );
    }

    function tokenSVG(uint256 _dna) public view returns (string memory) {
        (
            ChainRunnersBaseRenderer.Layer[NUM_LAYERS] memory tokenLayers,
            ChainRunnersBaseRenderer.Color[NUM_COLORS][NUM_LAYERS] memory tokenPalettes,
            uint8 numTokenLayers,
            string[NUM_LAYERS] memory traitTypes
        ) = getTokenData(_dna);

        string[4] memory buffer256 = tokenSVGBuffer(
            tokenLayers,
            tokenPalettes,
            numTokenLayers
        );
        return
            string(
                abi.encodePacked(
                    "PHN2ZyB2ZXJzaW9uPScxLjEnIHZpZXdCb3g9JzAgMCAzMjAgMzIwJyB4bWxucz0naHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmcnIHNoYXBlLXJlbmRlcmluZz0nY3Jpc3BFZGdlcyc+",
                    buffer256[0],
                    buffer256[1],
                    buffer256[2],
                    buffer256[3],
                    "PHN0eWxlPnJlY3R7d2lkdGg6MTBweDtoZWlnaHQ6MTBweDt9PC9zdHlsZT48L3N2Zz4"
                )
            );
    }

    function getTokenData(uint256 _dna) public view returns (ChainRunnersBaseRenderer.Layer [NUM_LAYERS] memory tokenLayers, ChainRunnersBaseRenderer.Color [NUM_COLORS][NUM_LAYERS] memory tokenPalettes, uint8 numTokenLayers, string [NUM_LAYERS] memory traitTypes) {
        uint16[NUM_LAYERS] memory dna = splitNumber(_dna);
        uint16 raceIndex = getRaceIndex(dna[1]);

        uint16 ogRaceIndex = chainRunnersBaseRenderer.getRaceIndex(dna[1]);

        bool hasFaceAcc = dna[7] < (10000 - WEIGHTS[ogRaceIndex][7][7]);
        bool hasMask = dna[8] < (10000 - WEIGHTS[ogRaceIndex][8][7]);
        bool hasHeadBelow = dna[9] < (10000 - WEIGHTS[ogRaceIndex][9][36]);
        bool hasHeadAbove = dna[11] < (10000 - WEIGHTS[ogRaceIndex][11][48]);
        bool useHeadAbove = (dna[0] % 2) > 0;
        for (uint8 i = 0; i < NUM_LAYERS; i ++) {
            ChainRunnersBaseRenderer.Layer memory layer = chainRunnersBaseRenderer.getLayer(i, uint8(getLayerIndex(dna[i], i, raceIndex, ogRaceIndex)));
            if (layer.hexString.length > 0) {
                if (((i == 2 || i == 12) && !hasMask && !hasFaceAcc) || (i == 7 && !hasMask) || (i == 10 && !hasMask) || (i < 2 || (i > 2 && i < 7) || i == 8 || i == 9 || i == 11)) {
                    if (hasHeadBelow && hasHeadAbove && (i == 9 && useHeadAbove) || (i == 11 && !useHeadAbove)) continue;
                    tokenLayers[numTokenLayers] = layer;
                    tokenPalettes[numTokenLayers] = palette(tokenLayers[numTokenLayers].hexString);
                    traitTypes[numTokenLayers] = ["QmFja2dyb3VuZCAg","UmFjZSAg","RmFjZSAg","TW91dGgg","Tm9zZSAg","RXllcyAg","RWFyIEFjY2Vzc29yeSAg","RmFjZSBBY2Nlc3Nvcnkg","TWFzayAg","SGVhZCBCZWxvdyAg","RXllIEFjY2Vzc29yeSAg","SGVhZCBBYm92ZSAg","TW91dGggQWNjZXNzb3J5"][i];
                    numTokenLayers++;
                }
            }
        }
        return (tokenLayers, tokenPalettes, numTokenLayers, traitTypes);
    }

    function getRaceIndex(uint16 _dna) public pure returns (uint8) {
        if (_dna <= 875) { // alien -> skull
            return 1;
        
        } else if (_dna <= 2144) { // bot -> alien
            return 0;
        
        } else if (_dna <= 9934) { // human -> bot
            return 2;
        
        } else { // skull -> human
            return 0;
        }
    }

    function getRaceLayer(uint16 _dna) public pure returns (uint) {
        if (_dna <= 875) { // alien -> skull
            return (_dna % 3) + 12;
        
        } else if (_dna <= 2144) { // bot -> alien
            return 0;
        
        } else if (_dna <= 9934) { // human -> bot
            return 1;
        
        } else {
            return (_dna % 10) + 2; // skull -> human
        }
    }

    function getLayerIndex(uint16 _dna, uint8 _index, uint16 _raceIndex, uint16 _ogRaceIndex) public view returns (uint) {
        if (_index == 1) {
            return getRaceLayer(_dna);
        }

        uint16 lowerBound;
        uint16 percentage;
        for (uint8 i; i < WEIGHTS[_ogRaceIndex][_index].length; i++) {
            percentage = WEIGHTS[_ogRaceIndex][_index][i];
            if (_dna >= lowerBound && _dna < lowerBound + percentage && WEIGHTS[_raceIndex][_index][i] != 0) {
                return i;
            }
            lowerBound += percentage;
        }

        return chainRunnersBaseRenderer.getLayerIndex(_dna, _index, _raceIndex);
    }

    function splitNumber(uint256 _number) internal pure returns (uint16[NUM_LAYERS] memory numbers) {
        for (uint256 i = 0; i < numbers.length; i++) {
            numbers[i] = uint16(_number % 10000);
            _number >>= 14;
        }
        return numbers;
    }

    function tokenSVGBuffer(
        ChainRunnersBaseRenderer.Layer[NUM_LAYERS] memory tokenLayers,
        ChainRunnersBaseRenderer.Color[NUM_COLORS][NUM_LAYERS]
            memory tokenPalettes,
        uint8 numTokenLayers
    ) public view returns (string[4] memory) {
        string[32] memory lookup = [
            "MDAw",
            "MDEw",
            "MDIw",
            "MDMw",
            "MDQw",
            "MDUw",
            "MDYw",
            "MDcw",
            "MDgw",
            "MDkw",
            "MTAw",
            "MTEw",
            "MTIw",
            "MTMw",
            "MTQw",
            "MTUw",
            "MTYw",
            "MTcw",
            "MTgw",
            "MTkw",
            "MjAw",
            "MjEw",
            "MjIw",
            "MjMw",
            "MjQw",
            "MjUw",
            "MjYw",
            "Mjcw",
            "Mjgw",
            "Mjkw",
            "MzAw",
            "MzEw"
        ];
        ChainRunnersBaseRenderer.SVGCursor memory cursor;

        ChainRunnersBaseRenderer.Buffer memory buffer4;
        string[8] memory buffer32;
        string[4] memory buffer256;
        uint8 buffer32count;
        uint8 buffer256count;
        for (uint256 k = 32; k < 416; ) {
            cursor.color1 = colorForIndex(tokenLayers, k, 0, tokenPalettes, numTokenLayers);
            cursor.color2 = colorForIndex(tokenLayers, k, 1, tokenPalettes, numTokenLayers);
            cursor.color3 = colorForIndex(tokenLayers, k, 2, tokenPalettes, numTokenLayers);
            cursor.color4 = colorForIndex(tokenLayers, k, 3, tokenPalettes, numTokenLayers);
            buffer4.one = pixel4(lookup, cursor);
            cursor.x += 4;

            cursor.color1 = colorForIndex(tokenLayers, k, 4, tokenPalettes, numTokenLayers);
            cursor.color2 = colorForIndex(tokenLayers, k, 5, tokenPalettes, numTokenLayers);
            cursor.color3 = colorForIndex(tokenLayers, k, 6, tokenPalettes, numTokenLayers);
            cursor.color4 = colorForIndex(tokenLayers, k, 7, tokenPalettes, numTokenLayers);
            buffer4.two = pixel4(lookup, cursor);
            cursor.x += 4;

            k += 3;

            cursor.color1 = colorForIndex(tokenLayers, k, 0, tokenPalettes, numTokenLayers);
            cursor.color2 = colorForIndex(tokenLayers, k, 1, tokenPalettes, numTokenLayers);
            cursor.color3 = colorForIndex(tokenLayers, k, 2, tokenPalettes, numTokenLayers);
            cursor.color4 = colorForIndex(tokenLayers, k, 3, tokenPalettes, numTokenLayers);
            buffer4.three = pixel4(lookup, cursor);
            cursor.x += 4;

            cursor.color1 = colorForIndex(tokenLayers, k, 4, tokenPalettes, numTokenLayers);
            cursor.color2 = colorForIndex(tokenLayers, k, 5, tokenPalettes, numTokenLayers);
            cursor.color3 = colorForIndex(tokenLayers, k, 6, tokenPalettes, numTokenLayers);
            cursor.color4 = colorForIndex(tokenLayers, k, 7, tokenPalettes, numTokenLayers);
            buffer4.four = pixel4(lookup, cursor);
            cursor.x += 4;

            k += 3;

            cursor.color1 = colorForIndex(tokenLayers, k, 0, tokenPalettes, numTokenLayers);
            cursor.color2 = colorForIndex(tokenLayers, k, 1, tokenPalettes, numTokenLayers);
            cursor.color3 = colorForIndex(tokenLayers, k, 2, tokenPalettes, numTokenLayers);
            cursor.color4 = colorForIndex(tokenLayers, k, 3, tokenPalettes, numTokenLayers);
            buffer4.five = pixel4(lookup, cursor);
            cursor.x += 4;

            cursor.color1 = colorForIndex(tokenLayers, k, 4, tokenPalettes, numTokenLayers);
            cursor.color2 = colorForIndex(tokenLayers, k, 5, tokenPalettes, numTokenLayers);
            cursor.color3 = colorForIndex(tokenLayers, k, 6, tokenPalettes, numTokenLayers);
            cursor.color4 = colorForIndex(tokenLayers, k, 7, tokenPalettes, numTokenLayers);
            buffer4.six = pixel4(lookup, cursor);
            cursor.x += 4;

            k += 3;

            cursor.color1 = colorForIndex(tokenLayers, k, 0, tokenPalettes, numTokenLayers);
            cursor.color2 = colorForIndex(tokenLayers, k, 1, tokenPalettes, numTokenLayers);
            cursor.color3 = colorForIndex(tokenLayers, k, 2, tokenPalettes, numTokenLayers);
            cursor.color4 = colorForIndex(tokenLayers, k, 3, tokenPalettes, numTokenLayers);
            buffer4.seven = pixel4(lookup, cursor);
            cursor.x += 4;

            cursor.color1 = colorForIndex(tokenLayers, k, 4, tokenPalettes, numTokenLayers);
            cursor.color2 = colorForIndex(tokenLayers, k, 5, tokenPalettes, numTokenLayers);
            cursor.color3 = colorForIndex(tokenLayers, k, 6, tokenPalettes, numTokenLayers);
            cursor.color4 = colorForIndex(tokenLayers, k, 7, tokenPalettes, numTokenLayers);
            buffer4.eight = pixel4(lookup, cursor);
            cursor.x += 4;

            k += 3;

            buffer32[buffer32count++] = string(
                abi.encodePacked(
                    buffer4.one,
                    buffer4.two,
                    buffer4.three,
                    buffer4.four,
                    buffer4.five,
                    buffer4.six,
                    buffer4.seven,
                    buffer4.eight
                )
            );
            cursor.x = 0;
            cursor.y += 1;
            if (buffer32count >= 8) {
                buffer256[buffer256count++] = string(
                    abi.encodePacked(
                        buffer32[0],
                        buffer32[1],
                        buffer32[2],
                        buffer32[3],
                        buffer32[4],
                        buffer32[5],
                        buffer32[6],
                        buffer32[7]
                    )
                );
                buffer32count = 0;
            }
        }

        return buffer256;
    }

    function palette(bytes memory data)
        internal
        view
        returns (ChainRunnersBaseRenderer.Color[NUM_COLORS] memory)
    {
        ChainRunnersBaseRenderer.Color[NUM_COLORS] memory colors;
        for (uint16 i = 0; i < NUM_COLORS; i++) {
            colors[i].hexString = Base64.encode(
                bytes(
                    abi.encodePacked(
                        chainRunnersBaseRenderer.byteToHexString(data[i * 4]),
                        chainRunnersBaseRenderer.byteToHexString(
                            data[i * 4 + 1]
                        ),
                        chainRunnersBaseRenderer.byteToHexString(
                            data[i * 4 + 2]
                        )
                    )
                )
            );
            colors[i].red = chainRunnersBaseRenderer.byteToUint(data[i * 4]);
            colors[i].green = chainRunnersBaseRenderer.byteToUint(
                data[i * 4 + 1]
            );
            colors[i].blue = chainRunnersBaseRenderer.byteToUint(
                data[i * 4 + 2]
            );
            colors[i].alpha = chainRunnersBaseRenderer.byteToUint(
                data[i * 4 + 3]
            );
        }
        return colors;
    }

    function colorForIndex(
        ChainRunnersBaseRenderer.Layer[NUM_LAYERS] memory tokenLayers,
        uint256 k,
        uint256 index,
        ChainRunnersBaseRenderer.Color[NUM_COLORS][NUM_LAYERS] memory palettes,
        uint256 numTokenLayers
    ) internal view returns (string memory) {
        for (uint256 i = numTokenLayers - 1; i >= 0; i--) {
            ChainRunnersBaseRenderer.Color memory fg = palettes[i][
                colorIndex(tokenLayers[i].hexString, k, index)
            ];

            if (fg.alpha == 0) {
                continue;
            } else if (fg.alpha == 255) {
                return fg.hexString;

            } else {
                for (uint256 j = i - 1; j >= 0; j--) {
                    ChainRunnersBaseRenderer.Color memory bg = palettes[j][
                        colorIndex(tokenLayers[j].hexString, k, index)
                    ];

                    if (bg.alpha > 0) {
                        return Base64.encode(bytes(blendColorsHexString(fg, bg)));
                    }
                }
            }
        }
        return "000000";
    }

    function equalStrings(string memory a, string memory b) private pure returns (bool) {
        return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    }

    function colorIndex(
        bytes memory data,
        uint256 k,
        uint256 index
    ) internal pure returns (uint8) {
        if (index == 0) {
            return uint8(data[k]) >> 5;
        } else if (index == 1) {
            return (uint8(data[k]) >> 2) % 8;
        } else if (index == 2) {
            return ((uint8(data[k]) % 4) * 2) + (uint8(data[k + 1]) >> 7);
        } else if (index == 3) {
            return (uint8(data[k + 1]) >> 4) % 8;
        } else if (index == 4) {
            return (uint8(data[k + 1]) >> 1) % 8;
        } else if (index == 5) {
            return ((uint8(data[k + 1]) % 2) * 4) + (uint8(data[k + 2]) >> 6);
        } else if (index == 6) {
            return (uint8(data[k + 2]) >> 3) % 8;
        } else {
            return uint8(data[k + 2]) % 8;
        }
    }

    function pixel4(
        string[32] memory lookup,
        ChainRunnersBaseRenderer.SVGCursor memory cursor
    ) internal pure returns (string memory result) {
        return
            string(
                abi.encodePacked(
                    "PHJlY3QgICBmaWxsPScj",
                    cursor.color1,
                    "JyAgeD0n",
                    lookup[31 - (cursor.x)],
                    "JyAgeT0n",
                    lookup[cursor.y],
                    "JyAvPjxyZWN0ICBmaWxsPScj",
                    cursor.color2,
                    "JyAgeD0n",
                    lookup[31 - (cursor.x + 1)],
                    "JyAgeT0n",
                    lookup[cursor.y],
                    "JyAvPjxyZWN0ICBmaWxsPScj",
                    cursor.color3,
                    "JyAgeD0n",
                    lookup[31 - (cursor.x + 2)],
                    "JyAgeT0n",
                    lookup[cursor.y],
                    "JyAvPjxyZWN0ICBmaWxsPScj",
                    cursor.color4,
                    "JyAgeD0n",
                    lookup[31 - (cursor.x + 3)],
                    "JyAgeT0n",
                    lookup[cursor.y],
                    "JyAgIC8+"
                )
            );
    }

    function blendColorsHexString(
        ChainRunnersBaseRenderer.Color memory fg,
        ChainRunnersBaseRenderer.Color memory bg
    ) internal view returns (string memory) {
        uint256 alpha = uint16(fg.alpha + 1);
        uint256 inv_alpha = uint16(256 - fg.alpha);
        return
            chainRunnersBaseRenderer.uintToHexString6(
                uint24((alpha * fg.blue + inv_alpha * bg.blue) >> 8) +
                    (uint24((alpha * fg.green + inv_alpha * bg.green) >> 8) <<
                        8) +
                    (uint24((alpha * fg.red + inv_alpha * bg.red) >> 8) << 16)
            );
    }

    function blendColors(
        ChainRunnersBaseRenderer.Color memory fg,
        ChainRunnersBaseRenderer.Color memory bg
    ) internal view returns (ChainRunnersBaseRenderer.Color memory) {
        uint256 alpha = uint16(fg.alpha + 1);
        uint256 inv_alpha = uint16(256 - fg.alpha);

        uint red = (alpha * fg.red + inv_alpha * bg.red) >> 8;
        uint green = (alpha * fg.green + inv_alpha * bg.green) >> 8;
        uint blue = (alpha * fg.blue + inv_alpha * bg.blue) >> 8;

        return ChainRunnersBaseRenderer.Color(
            chainRunnersBaseRenderer.uintToHexString6(blue + (green << 8) + (blue << 16)),
            255,
            red,
            green,
            blue
        );
    }

    function uintToByteString(uint256 a, uint256 fixedLen)
        internal
        pure
        returns (bytes memory _uintAsString)
    {
        uint256 j = a;
        uint256 len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(fixedLen);
        j = fixedLen;
        if (a == 0) {
            bstr[0] = "0";
            len = 1;
        }
        while (j > len) {
            j = j - 1;
            bstr[j] = bytes1(" ");
        }
        uint256 k = len;
        while (a != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(a - (a / 10) * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            a /= 10;
        }
        return bstr;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

interface ChainRunnersTypes {
    struct ChainRunner {
        uint256 dna;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./core/ChainRunnersTypes.sol";

/*
               ::::                                                                                                                                                  :::#%=
               @*==+-                                                                                                                                               ++==*=.
               #+=#=++..                                                                                                                                        ..=*=*+-#:
                :=+++++++=====================================:    .===============================================. .=========================================++++++++=
                 .%-+%##+=--==================================+=..=+-=============================================-+*+======================================---+##+=#-.
                   [email protected]@%[email protected]@@%+++++++++++++++++++++++++++%#++++++%#+++#@@@#[email protected]@%[email protected]#+.=+*@*+*@@@@*+++++++++++++++++++++++%@@@#+++#@@+++=
                    -*-#%@@%%%=*%@%*++=++=+==+=++=++=+=++=++==#@%#%#+++=+=*@%*+=+==+=+++%*[email protected]%%#%#++++*@%#++=++=++=++=+=++=++=+=+*%%*==*%@@@*:%=
                     :@:[email protected]@@@@@*+++%@@*+===========+*=========#@@========+#%==========*@========##*#*+=======*@##*======#@#+=======*#*============+#%++#@@%#@@#++=.
                      .*+=%@%*%@%##[email protected]@%#=-==-=--==*%=========*%==--=--=-====--=--=-=##=--=-=--%%%%%+=-=--=-=*%=--=--=-=#%=--=----=#%=--=-=--=-+%#+==#%@@*#%@=++.
                        +%.#@@###%@@@@@%*---------#@%########@%*---------------------##---------------------##---------%%*[email protected]@#---------+#@=#@@#[email protected]@%*++-
                        .:*+*%@#+=*%@@@*=-------=#%#=-------=%*---------=*#*--------#+=--------===--------=#%*-------=#%*[email protected]%#--------=%@@%#*+=-+#%*+*:.
       ====================%*[email protected]@%#==+##%@*[email protected]#[email protected]@*-------=*@[email protected]@*[email protected][email protected]=--------*@@+-------+#@@%#==---+#@.*%====================
     :*=--==================-:=#@@%*===+*@%+=============%%%@=========*%@*[email protected]+=--=====+%@[email protected][email protected]========*%@@+======%%%**+=---=%@#=:-====================-#-
       +++**%@@@#*****************@#*=---=##%@@@@@@@@@@@@@#**@@@@****************%@@*[email protected]#***********#@************************************+=------=*@#*********************@#+=+:
        .-##=*@@%*----------------+%@%=---===+%@@@@@@@*+++---%#++----------------=*@@*+++=-----------=+#=------------------------------------------+%+--------------------+#@[email protected]
         :%:#%#####+=-=-*@@+--=-==-=*@=--=-==-=*@@#*[email protected][email protected]%===-==----+-==-==--+*+-==-==---=*@@@@@@%#===-=-=+%@%-==-=-==-#@%=-==-==--+#@@@@@@@@@@@@*+++
        =*=#@#=----==-=-=++=--=-==-=*@=--=-==-=*@@[email protected]===-=--=-*@@*[email protected]=--=-==--+#@-==-==---+%-==-==---=+++#@@@#--==-=-=++++-=--=-===#%[email protected]@@%.#*
        +#:@%*===================++%#=========%@%=========#%=========+#@%+=======#%==========*@#=========*%=========+*+%@@@+========+*[email protected]@%+**+================*%#*=+=
       *++#@*+=++++++*#%*+++++=+++*%%++++=++++%%*=+++++++##*=++++=++=%@@++++=++=+#%++++=++++#%@=+++++++=*#*+++++++=#%@@@@@*++=++++=#%@*[email protected]#*****=+++++++=+++++*%@@+:=+=
    :=*=#%#@@@@#%@@@%#@@#++++++++++%%*+++++++++++++++++**@*+++++++++*%#++++++++=*##++++++++*%@%+++++++++##+++++++++#%%%%%%++++**#@@@@@**+++++++++++++++++=*%@@@%#@@@@#%@@@%#@++*:.
    #*:@#=-+%#+:=*@*[email protected]%#++++++++#%@@#*++++++++++++++#%@#*++++++++*@@#[email protected]#++++++++*@@#+++++++++##*+++++++++++++++++###@@@@++*@@#+++++++++++++++++++*@@#=:+#%[email protected]*=-+%*[email protected]=
    ++=#%#+%@@%=#%@%#+%%#++++++*#@@@%###**************@@@++++++++**#@##*********#*********#@@#++++++***@#******%@%#*++**#@@@%##+==+++=*#**********%%*++++++++#%#=%@@%+*%@%*+%#*=*-
     .-*+===========*@@+++++*%%%@@@++***************+.%%*++++#%%%@@%=:=******************[email protected]@#+++*%%@#==+***--*@%*++*%@@*===+**=--   -************[email protected]%%#++++++#@@@*==========*+-
        =*******##.#%#++++*%@@@%+==+=             *#-%@%**%%###*====**-               [email protected]:*@@##@###*==+**-.-#[email protected]@#*@##*==+***=                     =+=##%@*+++++*%@@#.#%******:
               ++++%#+++*#@@@@+++==.              **[email protected]@@%+++++++===-                 -+++#@@+++++++==:  :+++%@@+++++++==:                          [email protected]%##[email protected]@%++++
             :%:*%%****%@@%+==*-                .%==*====**+...                      #*.#+==***....    #+=#%+==****:.                                ..-*=*%@%#++*#%@=+%.
            -+++#%+#%@@@#++===                  [email protected]*++===-                            #%++===           %#+++===                                          =+++%@%##**@@*[email protected]:
          .%-=%@##@@%*==++                                                                                                                                 .*==+#@@%*%@%=*=.
         .+++#@@@@@*++==.                                                                                                                                    -==++#@@@@@@=+%
       .=*=%@@%%%#=*=.                                                                                                                                          .*+=%@@@@%+-#.
       @[email protected]@@%:++++.                                                                                                                                              -+++**@@#+*=:
    .-+=*#%%++*::.                                                                                                                                                  :+**=#%@#==#
    #*:@*+++=:                                                                                                                                                          [email protected]*++=:
  :*-=*=++..                                                                                                                                                             .=*=#*.%=
 +#.=+++:                                                                                                                                                                   ++++:+#
*+=#-::                                                                                                                                                                      .::*+=*

*/

contract ChainRunnersBaseRenderer is Ownable, ReentrancyGuard {
    struct SVGCursor {
        uint8 x;
        uint8 y;
        string color1;
        string color2;
        string color3;
        string color4;
    }

    struct Buffer {
        string one;
        string two;
        string three;
        string four;
        string five;
        string six;
        string seven;
        string eight;
    }

    struct Color {
        string hexString;
        uint alpha;
        uint red;
        uint green;
        uint blue;
    }

    struct Layer {
        string name;
        bytes hexString;
    }

    struct LayerInput {
        string name;
        bytes hexString;
        uint8 layerIndex;
        uint8 itemIndex;
    }

    uint256 public constant NUM_LAYERS = 13;
    uint256 public constant NUM_COLORS = 8;

    mapping(uint256 => Layer) [NUM_LAYERS] layers;

    /*
    This indexes into a race, then a layer index, then an array capturing the frequency each layer should be selected.
    Shout out to Anonymice for the rarity impl inspiration.
    */
    uint16[][NUM_LAYERS][3] WEIGHTS;

    constructor() {
        // Default
        WEIGHTS[0][0] = [36, 225, 225, 225, 360, 135, 27, 360, 315, 315, 315, 315, 225, 180, 225, 180, 360, 180, 45, 360, 360, 360, 27, 36, 360, 45, 180, 360, 225, 360, 225, 225, 360, 180, 45, 360, 18, 225, 225, 225, 225, 180, 225, 361];
        WEIGHTS[0][1] = [875, 1269, 779, 779, 779, 779, 779, 779, 779, 779, 779, 779, 17, 8, 41]; // race layers
        WEIGHTS[0][2] = [303, 303, 303, 303, 151, 30, 0, 0, 151, 151, 151, 151, 30, 303, 151, 30, 303, 303, 303, 303, 303, 303, 30, 151, 303, 303, 303, 303, 303, 303, 303, 303, 3066];
        WEIGHTS[0][3] = [645, 0, 1290, 322, 645, 645, 645, 967, 322, 967, 645, 967, 967, 973];
        WEIGHTS[0][4] = [0, 0, 0, 1250, 1250, 1250, 1250, 1250, 1250, 1250, 1250];
        WEIGHTS[0][5] = [121, 121, 121, 121, 121, 121, 243, 0, 0, 0, 0, 121, 121, 243, 121, 121, 243, 121, 121, 121, 121, 121, 243, 121, 121, 121, 121, 243, 121, 121, 121, 121, 243, 121, 121, 121, 243, 121, 121, 121, 121, 243, 121, 121, 121, 121, 243, 121, 121, 121, 121, 243, 121, 121, 121, 121, 243, 121, 121, 121, 121, 243, 121, 121, 243, 0, 0, 0, 121, 121, 243, 121, 121, 306];
        WEIGHTS[0][6] = [925, 555, 185, 555, 925, 925, 185, 1296, 1296, 1296, 1857];
        WEIGHTS[0][7] = [88, 88, 88, 88, 88, 265, 442, 8853];
        WEIGHTS[0][8] = [189, 189, 47, 18, 9, 28, 37, 9483];
        WEIGHTS[0][9] = [340, 340, 340, 340, 340, 340, 34, 340, 340, 340, 340, 170, 170, 170, 102, 238, 238, 238, 272, 340, 340, 340, 272, 238, 238, 238, 238, 170, 34, 340, 340, 136, 340, 340, 340, 340, 344];
        WEIGHTS[0][10] = [159, 212, 106, 53, 26, 159, 53, 265, 53, 212, 159, 265, 53, 265, 265, 212, 53, 159, 239, 53, 106, 5, 106, 53, 212, 212, 106, 159, 212, 265, 212, 265, 5066];
        WEIGHTS[0][11] = [139, 278, 278, 250, 250, 194, 222, 278, 278, 194, 222, 83, 222, 278, 139, 139, 27, 278, 278, 278, 278, 27, 278, 139, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 27, 139, 139, 139, 139, 0, 278, 194, 83, 83, 278, 83, 27, 306];
        WEIGHTS[0][12] = [981, 2945, 654, 16, 981, 327, 654, 163, 3279];

        // Skull
        WEIGHTS[1][0] = [36, 225, 225, 225, 360, 135, 27, 360, 315, 315, 315, 315, 225, 180, 225, 180, 360, 180, 45, 360, 360, 360, 27, 36, 360, 45, 180, 360, 225, 360, 225, 225, 360, 180, 45, 360, 18, 225, 225, 225, 225, 180, 225, 361];
        WEIGHTS[1][1] = [875, 1269, 779, 779, 779, 779, 779, 779, 779, 779, 779, 779, 17, 8, 41];
        WEIGHTS[1][2] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10000];
        WEIGHTS[1][3] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        WEIGHTS[1][4] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
        WEIGHTS[1][5] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 384, 7692, 1923, 0, 0, 0, 0, 0, 1];
        WEIGHTS[1][6] = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10000];
        WEIGHTS[1][7] = [0, 0, 0, 0, 0, 909, 0, 9091];
        WEIGHTS[1][8] = [0, 0, 0, 0, 0, 0, 0, 10000];
        WEIGHTS[1][9] = [526, 526, 526, 0, 0, 0, 0, 0, 526, 0, 0, 0, 526, 0, 526, 0, 0, 0, 526, 526, 526, 526, 526, 526, 526, 526, 526, 526, 526, 0, 0, 526, 0, 0, 0, 0, 532];
        WEIGHTS[1][10] = [80, 0, 400, 240, 80, 0, 240, 0, 0, 80, 80, 80, 0, 0, 0, 0, 80, 80, 0, 0, 80, 80, 0, 80, 80, 80, 80, 80, 0, 0, 0, 0, 8000];
        WEIGHTS[1][11] = [289, 0, 0, 0, 0, 404, 462, 578, 578, 0, 462, 173, 462, 578, 0, 0, 57, 0, 57, 0, 57, 57, 578, 289, 578, 57, 0, 57, 57, 57, 578, 578, 0, 0, 0, 0, 0, 0, 57, 289, 578, 0, 0, 0, 231, 57, 0, 0, 1745];
        WEIGHTS[1][12] = [714, 714, 714, 0, 714, 0, 0, 0, 7144];

        // Bot
        WEIGHTS[2][0] = [36, 225, 225, 225, 360, 135, 27, 360, 315, 315, 315, 315, 225, 180, 225, 180, 360, 180, 45, 360, 360, 360, 27, 36, 360, 45, 180, 360, 225, 360, 225, 225, 360, 180, 45, 360, 18, 225, 225, 225, 225, 180, 225, 361];
        WEIGHTS[2][1] = [875, 1269, 779, 779, 779, 779, 779, 779, 779, 779, 779, 779, 17, 8, 41];
        WEIGHTS[2][2] = [303, 303, 303, 303, 151, 30, 0, 0, 151, 151, 151, 151, 30, 303, 151, 30, 303, 303, 303, 303, 303, 303, 30, 151, 303, 303, 303, 303, 303, 303, 303, 303, 3066];
        WEIGHTS[2][3] = [645, 0, 1290, 322, 645, 645, 645, 967, 322, 967, 645, 967, 967, 973];
        WEIGHTS[2][4] = [2500, 2500, 2500, 0, 0, 0, 0, 0, 0, 2500, 0];
        WEIGHTS[2][5] = [0, 0, 0, 0, 0, 0, 588, 588, 588, 588, 588, 0, 0, 588, 0, 0, 588, 0, 0, 0, 0, 0, 588, 0, 0, 0, 0, 588, 0, 0, 0, 588, 588, 0, 0, 0, 588, 0, 0, 0, 0, 588, 0, 0, 0, 0, 0, 0, 0, 0, 0, 588, 0, 0, 0, 0, 588, 0, 0, 0, 0, 588, 0, 0, 0, 0, 0, 0, 0, 0, 588, 0, 0, 4];
        WEIGHTS[2][6] = [925, 555, 185, 555, 925, 925, 185, 1296, 1296, 1296, 1857];
        WEIGHTS[2][7] = [88, 88, 88, 88, 88, 265, 442, 8853];
        WEIGHTS[2][8] = [183, 274, 274, 18, 18, 27, 36, 9170];
        WEIGHTS[2][9] = [340, 340, 340, 340, 340, 340, 34, 340, 340, 340, 340, 170, 170, 170, 102, 238, 238, 238, 272, 340, 340, 340, 272, 238, 238, 238, 238, 170, 34, 340, 340, 136, 340, 340, 340, 340, 344];
        WEIGHTS[2][10] = [217, 362, 217, 144, 72, 289, 144, 362, 72, 289, 217, 362, 72, 362, 362, 289, 0, 217, 0, 72, 144, 7, 217, 72, 217, 217, 289, 217, 289, 362, 217, 362, 3269];
        WEIGHTS[2][11] = [139, 278, 278, 250, 250, 194, 222, 278, 278, 194, 222, 83, 222, 278, 139, 139, 27, 278, 278, 278, 278, 27, 278, 139, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 278, 27, 139, 139, 139, 139, 0, 278, 194, 83, 83, 278, 83, 27, 306];
        WEIGHTS[2][12] = [981, 2945, 654, 16, 981, 327, 654, 163, 3279];
    }

    function setLayers(LayerInput[] calldata toSet) external onlyOwner {
        for (uint16 i = 0; i < toSet.length; i++) {
            layers[toSet[i].layerIndex][toSet[i].itemIndex] = Layer(toSet[i].name, toSet[i].hexString);
        }
    }

    function getLayer(uint8 layerIndex, uint8 itemIndex) public view returns (Layer memory) {
        return layers[layerIndex][itemIndex];
    }

    /*
    Get race index.  Race index represents the "type" of base character:

    0 - Default, representing human and alien characters
    1 - Skull
    2 - Bot

    This allows skull/bot characters to have distinct trait distributions.
    */
    function getRaceIndex(uint16 _dna) public view returns (uint8) {
        uint16 lowerBound;
        uint16 percentage;
        for (uint8 i; i < WEIGHTS[0][1].length; i++) {
            percentage = WEIGHTS[0][1][i];
            if (_dna >= lowerBound && _dna < lowerBound + percentage) {
                if (i == 1) {
                    // Bot
                    return 2;
                } else if (i > 11) {
                    // Skull
                    return 1;
                } else {
                    // Default
                    return 0;
                }
            }
            lowerBound += percentage;
        }
        revert();
    }

    function getLayerIndex(uint16 _dna, uint8 _index, uint16 _raceIndex) public view returns (uint) {
        uint16 lowerBound;
        uint16 percentage;
        for (uint8 i; i < WEIGHTS[_raceIndex][_index].length; i++) {
            percentage = WEIGHTS[_raceIndex][_index][i];
            if (_dna >= lowerBound && _dna < lowerBound + percentage) {
                return i;
            }
            lowerBound += percentage;
        }
        // If not found, return index higher than available layers.  Will get filtered out.
        return WEIGHTS[_raceIndex][_index].length;
    }

    /*
    Generate base64 encoded tokenURI.

    All string constants are pre-base64 encoded to save gas.
    Input strings are padded with spacing/etc to ensure their length is a multiple of 3.
    This way the resulting base64 encoded string is a multiple of 4 and will not include any '=' padding characters,
    which allows these base64 string snippets to be concatenated with other snippets.
    */
    function tokenURI(uint256 tokenId, ChainRunnersTypes.ChainRunner memory runnerData) public view returns (string memory) {
        (Layer [NUM_LAYERS] memory tokenLayers, Color [NUM_COLORS][NUM_LAYERS] memory tokenPalettes, uint8 numTokenLayers, string[NUM_LAYERS] memory traitTypes) = getTokenData(runnerData.dna);
        string memory attributes;
        for (uint8 i = 0; i < numTokenLayers; i++) {
            attributes = string(abi.encodePacked(attributes,
                bytes(attributes).length == 0 ? 'eyAg' : 'LCB7',
                'InRyYWl0X3R5cGUiOiAi', traitTypes[i], 'IiwidmFsdWUiOiAi', tokenLayers[i].name, 'IiB9'
                ));
        }
        string[4] memory svgBuffers = tokenSVGBuffer(tokenLayers, tokenPalettes, numTokenLayers);
        return string(abi.encodePacked(
                'data:application/json;base64,eyAgImltYWdlX2RhdGEiOiAiPHN2ZyB2ZXJzaW9uPScxLjEnIHZpZXdCb3g9JzAgMCAzMjAgMzIwJyB4bWxucz0naHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmcnIHNoYXBlLXJlbmRlcmluZz0nY3Jpc3BFZGdlcyc+',
                svgBuffers[0], svgBuffers[1], svgBuffers[2], svgBuffers[3],
                'PHN0eWxlPnJlY3R7d2lkdGg6MTBweDtoZWlnaHQ6MTBweDt9PC9zdHlsZT48L3N2Zz4gIiwgImF0dHJpYnV0ZXMiOiBb',
                attributes,
                'XSwgICAibmFtZSI6IlJ1bm5lciAj',
                Base64.encode(uintToByteString(tokenId, 6)),
                'IiwgImRlc2NyaXB0aW9uIjogIkNoYWluIFJ1bm5lcnMgYXJlIE1lZ2EgQ2l0eSByZW5lZ2FkZXMgMTAwJSBnZW5lcmF0ZWQgb24gY2hhaW4uIn0g'
            ));
    }

    function tokenSVG(uint256 _dna) public view returns (string memory) {
        (Layer [NUM_LAYERS] memory tokenLayers, Color [NUM_COLORS][NUM_LAYERS] memory tokenPalettes, uint8 numTokenLayers, string[NUM_LAYERS] memory traitTypes) = getTokenData(_dna);
        string[4] memory buffer256 = tokenSVGBuffer(tokenLayers, tokenPalettes, numTokenLayers);
        return string(abi.encodePacked(
                "PHN2ZyB2ZXJzaW9uPScxLjEnIHZpZXdCb3g9JzAgMCAzMiAzMicgeG1sbnM9J2h0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnJyBzaGFwZS1yZW5kZXJpbmc9J2NyaXNwRWRnZXMnIGhlaWdodD0nMTAwJScgd2lkdGg9JzEwMCUnICA+",
                buffer256[0], buffer256[1], buffer256[2], buffer256[3],
                "PHN0eWxlPnJlY3R7d2lkdGg6MXB4O2hlaWdodDoxcHg7fTwvc3R5bGU+PC9zdmc+"
            )
        );
    }

    function getTokenData(uint256 _dna) public view returns (Layer [NUM_LAYERS] memory tokenLayers, Color [NUM_COLORS][NUM_LAYERS] memory tokenPalettes, uint8 numTokenLayers, string [NUM_LAYERS] memory traitTypes) {
        uint16[NUM_LAYERS] memory dna = splitNumber(_dna);
        uint16 raceIndex = getRaceIndex(dna[1]);

        bool hasFaceAcc = dna[7] < (10000 - WEIGHTS[raceIndex][7][7]);
        bool hasMask = dna[8] < (10000 - WEIGHTS[raceIndex][8][7]);
        bool hasHeadBelow = dna[9] < (10000 - WEIGHTS[raceIndex][9][36]);
        bool hasHeadAbove = dna[11] < (10000 - WEIGHTS[raceIndex][11][48]);
        bool useHeadAbove = (dna[0] % 2) > 0;
        for (uint8 i = 0; i < NUM_LAYERS; i ++) {
            Layer memory layer = layers[i][getLayerIndex(dna[i], i, raceIndex)];
            if (layer.hexString.length > 0) {
                /*
                These conditions help make sure layer selection meshes well visually.
                1. If mask, no face/eye acc/mouth acc
                2. If face acc, no mask/mouth acc/face
                3. If both head above & head below, randomly choose one
                */
                if (((i == 2 || i == 12) && !hasMask && !hasFaceAcc) || (i == 7 && !hasMask) || (i == 10 && !hasMask) || (i < 2 || (i > 2 && i < 7) || i == 8 || i == 9 || i == 11)) {
                    if (hasHeadBelow && hasHeadAbove && (i == 9 && useHeadAbove) || (i == 11 && !useHeadAbove)) continue;
                    tokenLayers[numTokenLayers] = layer;
                    tokenPalettes[numTokenLayers] = palette(tokenLayers[numTokenLayers].hexString);
                    traitTypes[numTokenLayers] = ["QmFja2dyb3VuZCAg","UmFjZSAg","RmFjZSAg","TW91dGgg","Tm9zZSAg","RXllcyAg","RWFyIEFjY2Vzc29yeSAg","RmFjZSBBY2Nlc3Nvcnkg","TWFzayAg","SGVhZCBCZWxvdyAg","RXllIEFjY2Vzc29yeSAg","SGVhZCBBYm92ZSAg","TW91dGggQWNjZXNzb3J5"][i];
                    numTokenLayers++;
                }
            }
        }
        return (tokenLayers, tokenPalettes, numTokenLayers, traitTypes);
    }

    /*
    Generate svg rects, leaving un-concatenated to save a redundant concatenation in calling functions to reduce gas.
    Shout out to Blitmap for a lot of the inspiration for efficient rendering here.
    */
    function tokenSVGBuffer(Layer [NUM_LAYERS] memory tokenLayers, Color [NUM_COLORS][NUM_LAYERS] memory tokenPalettes, uint8 numTokenLayers) public pure returns (string[4] memory) {
        // Base64 encoded lookups into x/y position strings from 010 to 310.
        string[32] memory lookup = ["MDAw", "MDEw", "MDIw", "MDMw", "MDQw", "MDUw", "MDYw", "MDcw", "MDgw", "MDkw", "MTAw", "MTEw", "MTIw", "MTMw", "MTQw", "MTUw", "MTYw", "MTcw", "MTgw", "MTkw", "MjAw", "MjEw", "MjIw", "MjMw", "MjQw", "MjUw", "MjYw", "Mjcw", "Mjgw", "Mjkw", "MzAw", "MzEw"];
        SVGCursor memory cursor;

        /*
        Rather than concatenating the result string with itself over and over (e.g. result = abi.encodePacked(result, newString)),
        we fill up multiple levels of buffers.  This reduces redundant intermediate concatenations, performing O(log(n)) concats
        instead of O(n) concats.  Buffers beyond a length of about 12 start hitting stack too deep issues, so using a length of 8
        because the pixel math is convenient.
        */
        Buffer memory buffer4;
        // 4 pixels per slot, 32 total.  Struct is ever so slightly better for gas, so using when convenient.
        string[8] memory buffer32;
        // 32 pixels per slot, 256 total
        string[4] memory buffer256;
        // 256 pixels per slot, 1024 total
        uint8 buffer32count;
        uint8 buffer256count;
        for (uint k = 32; k < 416;) {
            cursor.color1 = colorForIndex(tokenLayers, k, 0, tokenPalettes, numTokenLayers);
            cursor.color2 = colorForIndex(tokenLayers, k, 1, tokenPalettes, numTokenLayers);
            cursor.color3 = colorForIndex(tokenLayers, k, 2, tokenPalettes, numTokenLayers);
            cursor.color4 = colorForIndex(tokenLayers, k, 3, tokenPalettes, numTokenLayers);
            buffer4.one = pixel4(lookup, cursor);
            cursor.x += 4;

            cursor.color1 = colorForIndex(tokenLayers, k, 4, tokenPalettes, numTokenLayers);
            cursor.color2 = colorForIndex(tokenLayers, k, 5, tokenPalettes, numTokenLayers);
            cursor.color3 = colorForIndex(tokenLayers, k, 6, tokenPalettes, numTokenLayers);
            cursor.color4 = colorForIndex(tokenLayers, k, 7, tokenPalettes, numTokenLayers);
            buffer4.two = pixel4(lookup, cursor);
            cursor.x += 4;

            k += 3;

            cursor.color1 = colorForIndex(tokenLayers, k, 0, tokenPalettes, numTokenLayers);
            cursor.color2 = colorForIndex(tokenLayers, k, 1, tokenPalettes, numTokenLayers);
            cursor.color3 = colorForIndex(tokenLayers, k, 2, tokenPalettes, numTokenLayers);
            cursor.color4 = colorForIndex(tokenLayers, k, 3, tokenPalettes, numTokenLayers);
            buffer4.three = pixel4(lookup, cursor);
            cursor.x += 4;

            cursor.color1 = colorForIndex(tokenLayers, k, 4, tokenPalettes, numTokenLayers);
            cursor.color2 = colorForIndex(tokenLayers, k, 5, tokenPalettes, numTokenLayers);
            cursor.color3 = colorForIndex(tokenLayers, k, 6, tokenPalettes, numTokenLayers);
            cursor.color4 = colorForIndex(tokenLayers, k, 7, tokenPalettes, numTokenLayers);
            buffer4.four = pixel4(lookup, cursor);
            cursor.x += 4;

            k += 3;

            cursor.color1 = colorForIndex(tokenLayers, k, 0, tokenPalettes, numTokenLayers);
            cursor.color2 = colorForIndex(tokenLayers, k, 1, tokenPalettes, numTokenLayers);
            cursor.color3 = colorForIndex(tokenLayers, k, 2, tokenPalettes, numTokenLayers);
            cursor.color4 = colorForIndex(tokenLayers, k, 3, tokenPalettes, numTokenLayers);
            buffer4.five = pixel4(lookup, cursor);
            cursor.x += 4;

            cursor.color1 = colorForIndex(tokenLayers, k, 4, tokenPalettes, numTokenLayers);
            cursor.color2 = colorForIndex(tokenLayers, k, 5, tokenPalettes, numTokenLayers);
            cursor.color3 = colorForIndex(tokenLayers, k, 6, tokenPalettes, numTokenLayers);
            cursor.color4 = colorForIndex(tokenLayers, k, 7, tokenPalettes, numTokenLayers);
            buffer4.six = pixel4(lookup, cursor);
            cursor.x += 4;

            k += 3;

            cursor.color1 = colorForIndex(tokenLayers, k, 0, tokenPalettes, numTokenLayers);
            cursor.color2 = colorForIndex(tokenLayers, k, 1, tokenPalettes, numTokenLayers);
            cursor.color3 = colorForIndex(tokenLayers, k, 2, tokenPalettes, numTokenLayers);
            cursor.color4 = colorForIndex(tokenLayers, k, 3, tokenPalettes, numTokenLayers);
            buffer4.seven = pixel4(lookup, cursor);
            cursor.x += 4;

            cursor.color1 = colorForIndex(tokenLayers, k, 4, tokenPalettes, numTokenLayers);
            cursor.color2 = colorForIndex(tokenLayers, k, 5, tokenPalettes, numTokenLayers);
            cursor.color3 = colorForIndex(tokenLayers, k, 6, tokenPalettes, numTokenLayers);
            cursor.color4 = colorForIndex(tokenLayers, k, 7, tokenPalettes, numTokenLayers);
            buffer4.eight = pixel4(lookup, cursor);
            cursor.x += 4;

            k += 3;

            buffer32[buffer32count++] = string(abi.encodePacked(buffer4.one, buffer4.two, buffer4.three, buffer4.four, buffer4.five, buffer4.six, buffer4.seven, buffer4.eight));
            cursor.x = 0;
            cursor.y += 1;
            if (buffer32count >= 8) {
                buffer256[buffer256count++] = string(abi.encodePacked(buffer32[0], buffer32[1], buffer32[2], buffer32[3], buffer32[4], buffer32[5], buffer32[6], buffer32[7]));
                buffer32count = 0;
            }
        }
        // At this point, buffer256 contains 4 strings or 256*4=1024=32x32 pixels
        return buffer256;
    }

    function palette(bytes memory data) internal pure returns (Color [NUM_COLORS] memory) {
        Color [NUM_COLORS] memory colors;
        for (uint16 i = 0; i < NUM_COLORS; i++) {
            // Even though this can be computed later from the RGBA values below, it saves gas to pre-compute it once upfront.
            colors[i].hexString = Base64.encode(bytes(abi.encodePacked(
                    byteToHexString(data[i * 4]),
                    byteToHexString(data[i * 4 + 1]),
                    byteToHexString(data[i * 4 + 2])
                )));
            colors[i].red = byteToUint(data[i * 4]);
            colors[i].green = byteToUint(data[i * 4 + 1]);
            colors[i].blue = byteToUint(data[i * 4 + 2]);
            colors[i].alpha = byteToUint(data[i * 4 + 3]);
        }
        return colors;
    }

    function colorForIndex(Layer[NUM_LAYERS] memory tokenLayers, uint k, uint index, Color [NUM_COLORS][NUM_LAYERS] memory palettes, uint numTokenLayers) internal pure returns (string memory) {
        for (uint256 i = numTokenLayers - 1; i >= 0; i--) {
            Color memory fg = palettes[i][colorIndex(tokenLayers[i].hexString, k, index)];
            // Since most layer pixels are transparent, performing this check first saves gas
            if (fg.alpha == 0) {
                continue;
            } else if (fg.alpha == 255) {
                return fg.hexString;
            } else {
                for (uint256 j = i - 1; j >= 0; j--) {
                    Color memory bg = palettes[j][colorIndex(tokenLayers[j].hexString, k, index)];
                    /* As a simplification, blend with first non-transparent layer then stop.
                    We won't generally have overlapping semi-transparent pixels.
                    */
                    if (bg.alpha > 0) {
                        return Base64.encode(bytes(blendColors(fg, bg)));
                    }
                }
            }
        }
        return "000000";
    }

    /*
    Each color index is 3 bits (there are 8 colors, so 3 bits are needed to index into them).
    Since 3 bits doesn't divide cleanly into 8 bits (1 byte), we look up colors 24 bits (3 bytes) at a time.
    "k" is the starting byte index, and "index" is the color index within the 3 bytes starting at k.
    */
    function colorIndex(bytes memory data, uint k, uint index) internal pure returns (uint8) {
        if (index == 0) {
            return uint8(data[k]) >> 5;
        } else if (index == 1) {
            return (uint8(data[k]) >> 2) % 8;
        } else if (index == 2) {
            return ((uint8(data[k]) % 4) * 2) + (uint8(data[k + 1]) >> 7);
        } else if (index == 3) {
            return (uint8(data[k + 1]) >> 4) % 8;
        } else if (index == 4) {
            return (uint8(data[k + 1]) >> 1) % 8;
        } else if (index == 5) {
            return ((uint8(data[k + 1]) % 2) * 4) + (uint8(data[k + 2]) >> 6);
        } else if (index == 6) {
            return (uint8(data[k + 2]) >> 3) % 8;
        } else {
            return uint8(data[k + 2]) % 8;
        }
    }

    /*
    Create 4 svg rects, pre-base64 encoding the svg constants to save gas.
    */
    function pixel4(string[32] memory lookup, SVGCursor memory cursor) internal pure returns (string memory result) {
        return string(abi.encodePacked(
                "PHJlY3QgICBmaWxsPScj", cursor.color1, "JyAgeD0n", lookup[cursor.x], "JyAgeT0n", lookup[cursor.y],
                "JyAvPjxyZWN0ICBmaWxsPScj", cursor.color2, "JyAgeD0n", lookup[cursor.x + 1], "JyAgeT0n", lookup[cursor.y],
                "JyAvPjxyZWN0ICBmaWxsPScj", cursor.color3, "JyAgeD0n", lookup[cursor.x + 2], "JyAgeT0n", lookup[cursor.y],
                "JyAvPjxyZWN0ICBmaWxsPScj", cursor.color4, "JyAgeD0n", lookup[cursor.x + 3], "JyAgeT0n", lookup[cursor.y], "JyAgIC8+"
            ));
    }

    /*
    Blend colors, inspired by https://stackoverflow.com/a/12016968
    */
    function blendColors(Color memory fg, Color memory bg) internal pure returns (string memory) {
        uint alpha = uint16(fg.alpha + 1);
        uint inv_alpha = uint16(256 - fg.alpha);
        return uintToHexString6(uint24((alpha * fg.blue + inv_alpha * bg.blue) >> 8) + (uint24((alpha * fg.green + inv_alpha * bg.green) >> 8) << 8) + (uint24((alpha * fg.red + inv_alpha * bg.red) >> 8) << 16));
    }

    function splitNumber(uint256 _number) internal pure returns (uint16[NUM_LAYERS] memory numbers) {
        for (uint256 i = 0; i < numbers.length; i++) {
            numbers[i] = uint16(_number % 10000);
            _number >>= 14;
        }
        return numbers;
    }

    function uintToHexDigit(uint8 d) public pure returns (bytes1) {
        if (0 <= d && d <= 9) {
            return bytes1(uint8(bytes1('0')) + d);
        } else if (10 <= uint8(d) && uint8(d) <= 15) {
            return bytes1(uint8(bytes1('a')) + d - 10);
        }
        revert();
    }

    /*
    Convert uint to hex string, padding to 6 hex nibbles
    */
    function uintToHexString6(uint a) public pure returns (string memory) {
        string memory str = uintToHexString2(a);
        if (bytes(str).length == 2) {
            return string(abi.encodePacked("0000", str));
        } else if (bytes(str).length == 3) {
            return string(abi.encodePacked("000", str));
        } else if (bytes(str).length == 4) {
            return string(abi.encodePacked("00", str));
        } else if (bytes(str).length == 5) {
            return string(abi.encodePacked("0", str));
        }
        return str;
    }

    /*
    Convert uint to hex string, padding to 2 hex nibbles
    */
    function uintToHexString2(uint a) public pure returns (string memory) {
        uint count = 0;
        uint b = a;
        while (b != 0) {
            count++;
            b /= 16;
        }
        bytes memory res = new bytes(count);
        for (uint i = 0; i < count; ++i) {
            b = a % 16;
            res[count - i - 1] = uintToHexDigit(uint8(b));
            a /= 16;
        }

        string memory str = string(res);
        if (bytes(str).length == 0) {
            return "00";
        } else if (bytes(str).length == 1) {
            return string(abi.encodePacked("0", str));
        }
        return str;
    }

    /*
    Convert uint to byte string, padding number string with spaces at end.
    Useful to ensure result's length is a multiple of 3, and therefore base64 encoding won't
    result in '=' padding chars.
    */
    function uintToByteString(uint a, uint fixedLen) internal pure returns (bytes memory _uintAsString) {
        uint j = a;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(fixedLen);
        j = fixedLen;
        if (a == 0) {
            bstr[0] = "0";
            len = 1;
        }
        while (j > len) {
            j = j - 1;
            bstr[j] = bytes1(' ');
        }
        uint k = len;
        while (a != 0) {
            k = k - 1;
            uint8 temp = (48 + uint8(a - a / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            a /= 10;
        }
        return bstr;
    }

    function byteToUint(bytes1 b) public pure returns (uint) {
        return uint(uint8(b));
    }

    function byteToHexString(bytes1 b) public pure returns (string memory) {
        return uintToHexString2(byteToUint(b));
    }
}

/// [MIT License]
/// @title Base64
/// @notice Provides a function for encoding some bytes in base64
/// @author Brecht Devos <[email protected]>
library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    /// @notice Encodes some bytes to the base64 representation
    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        // multiply by 4/3 rounded up
        uint256 encodedLen = 4 * ((len + 2) / 3);

        // Add some extra buffer at the end
        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >= 0.4.22 <0.9.0;

library console {
	address constant CONSOLE_ADDRESS = address(0x000000000000000000636F6e736F6c652e6c6f67);

	function _sendLogPayload(bytes memory payload) private view {
		uint256 payloadLength = payload.length;
		address consoleAddress = CONSOLE_ADDRESS;
		assembly {
			let payloadStart := add(payload, 32)
			let r := staticcall(gas(), consoleAddress, payloadStart, payloadLength, 0, 0)
		}
	}

	function log() internal view {
		_sendLogPayload(abi.encodeWithSignature("log()"));
	}

	function logInt(int p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(int)", p0));
	}

	function logUint(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function logString(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function logBool(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function logAddress(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function logBytes(bytes memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes)", p0));
	}

	function logBytes1(bytes1 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes1)", p0));
	}

	function logBytes2(bytes2 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes2)", p0));
	}

	function logBytes3(bytes3 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes3)", p0));
	}

	function logBytes4(bytes4 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes4)", p0));
	}

	function logBytes5(bytes5 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes5)", p0));
	}

	function logBytes6(bytes6 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes6)", p0));
	}

	function logBytes7(bytes7 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes7)", p0));
	}

	function logBytes8(bytes8 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes8)", p0));
	}

	function logBytes9(bytes9 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes9)", p0));
	}

	function logBytes10(bytes10 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes10)", p0));
	}

	function logBytes11(bytes11 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes11)", p0));
	}

	function logBytes12(bytes12 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes12)", p0));
	}

	function logBytes13(bytes13 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes13)", p0));
	}

	function logBytes14(bytes14 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes14)", p0));
	}

	function logBytes15(bytes15 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes15)", p0));
	}

	function logBytes16(bytes16 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes16)", p0));
	}

	function logBytes17(bytes17 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes17)", p0));
	}

	function logBytes18(bytes18 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes18)", p0));
	}

	function logBytes19(bytes19 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes19)", p0));
	}

	function logBytes20(bytes20 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes20)", p0));
	}

	function logBytes21(bytes21 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes21)", p0));
	}

	function logBytes22(bytes22 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes22)", p0));
	}

	function logBytes23(bytes23 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes23)", p0));
	}

	function logBytes24(bytes24 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes24)", p0));
	}

	function logBytes25(bytes25 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes25)", p0));
	}

	function logBytes26(bytes26 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes26)", p0));
	}

	function logBytes27(bytes27 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes27)", p0));
	}

	function logBytes28(bytes28 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes28)", p0));
	}

	function logBytes29(bytes29 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes29)", p0));
	}

	function logBytes30(bytes30 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes30)", p0));
	}

	function logBytes31(bytes31 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes31)", p0));
	}

	function logBytes32(bytes32 p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bytes32)", p0));
	}

	function log(uint p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint)", p0));
	}

	function log(string memory p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string)", p0));
	}

	function log(bool p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool)", p0));
	}

	function log(address p0) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address)", p0));
	}

	function log(uint p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint)", p0, p1));
	}

	function log(uint p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string)", p0, p1));
	}

	function log(uint p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool)", p0, p1));
	}

	function log(uint p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address)", p0, p1));
	}

	function log(string memory p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint)", p0, p1));
	}

	function log(string memory p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string)", p0, p1));
	}

	function log(string memory p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool)", p0, p1));
	}

	function log(string memory p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address)", p0, p1));
	}

	function log(bool p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint)", p0, p1));
	}

	function log(bool p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string)", p0, p1));
	}

	function log(bool p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool)", p0, p1));
	}

	function log(bool p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address)", p0, p1));
	}

	function log(address p0, uint p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint)", p0, p1));
	}

	function log(address p0, string memory p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string)", p0, p1));
	}

	function log(address p0, bool p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool)", p0, p1));
	}

	function log(address p0, address p1) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address)", p0, p1));
	}

	function log(uint p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint)", p0, p1, p2));
	}

	function log(uint p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string)", p0, p1, p2));
	}

	function log(uint p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool)", p0, p1, p2));
	}

	function log(uint p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool)", p0, p1, p2));
	}

	function log(uint p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address)", p0, p1, p2));
	}

	function log(uint p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint)", p0, p1, p2));
	}

	function log(uint p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string)", p0, p1, p2));
	}

	function log(uint p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool)", p0, p1, p2));
	}

	function log(uint p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address)", p0, p1, p2));
	}

	function log(uint p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint)", p0, p1, p2));
	}

	function log(uint p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string)", p0, p1, p2));
	}

	function log(uint p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool)", p0, p1, p2));
	}

	function log(uint p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool)", p0, p1, p2));
	}

	function log(string memory p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool)", p0, p1, p2));
	}

	function log(string memory p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool)", p0, p1, p2));
	}

	function log(string memory p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address)", p0, p1, p2));
	}

	function log(string memory p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint)", p0, p1, p2));
	}

	function log(string memory p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string)", p0, p1, p2));
	}

	function log(string memory p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool)", p0, p1, p2));
	}

	function log(string memory p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address)", p0, p1, p2));
	}

	function log(bool p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint)", p0, p1, p2));
	}

	function log(bool p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string)", p0, p1, p2));
	}

	function log(bool p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool)", p0, p1, p2));
	}

	function log(bool p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool)", p0, p1, p2));
	}

	function log(bool p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address)", p0, p1, p2));
	}

	function log(bool p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint)", p0, p1, p2));
	}

	function log(bool p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string)", p0, p1, p2));
	}

	function log(bool p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool)", p0, p1, p2));
	}

	function log(bool p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address)", p0, p1, p2));
	}

	function log(bool p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint)", p0, p1, p2));
	}

	function log(bool p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string)", p0, p1, p2));
	}

	function log(bool p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool)", p0, p1, p2));
	}

	function log(bool p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address)", p0, p1, p2));
	}

	function log(address p0, uint p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint)", p0, p1, p2));
	}

	function log(address p0, uint p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string)", p0, p1, p2));
	}

	function log(address p0, uint p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool)", p0, p1, p2));
	}

	function log(address p0, uint p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address)", p0, p1, p2));
	}

	function log(address p0, string memory p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint)", p0, p1, p2));
	}

	function log(address p0, string memory p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string)", p0, p1, p2));
	}

	function log(address p0, string memory p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool)", p0, p1, p2));
	}

	function log(address p0, string memory p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address)", p0, p1, p2));
	}

	function log(address p0, bool p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint)", p0, p1, p2));
	}

	function log(address p0, bool p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string)", p0, p1, p2));
	}

	function log(address p0, bool p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool)", p0, p1, p2));
	}

	function log(address p0, bool p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address)", p0, p1, p2));
	}

	function log(address p0, address p1, uint p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint)", p0, p1, p2));
	}

	function log(address p0, address p1, string memory p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string)", p0, p1, p2));
	}

	function log(address p0, address p1, bool p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool)", p0, p1, p2));
	}

	function log(address p0, address p1, address p2) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address)", p0, p1, p2));
	}

	function log(uint p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,uint,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,string,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,bool,address,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,uint,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,string,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,bool,address)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,uint)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,string)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,bool)", p0, p1, p2, p3));
	}

	function log(uint p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(uint,address,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,uint,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,string,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,bool,address,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,uint,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,string,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,bool,address)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,uint)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,string)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,bool)", p0, p1, p2, p3));
	}

	function log(string memory p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(string,address,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,uint,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,string,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,bool,address,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,uint,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,string,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,bool,address)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,uint)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,string)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,bool)", p0, p1, p2, p3));
	}

	function log(bool p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(bool,address,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, uint p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,uint,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, string memory p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,string,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, bool p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,bool,address,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, uint p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,uint,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, string memory p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,string,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, bool p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,bool,address)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, uint p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,uint)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, string memory p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,string)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, bool p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,bool)", p0, p1, p2, p3));
	}

	function log(address p0, address p1, address p2, address p3) internal view {
		_sendLogPayload(abi.encodeWithSignature("log(address,address,address,address)", p0, p1, p2, p3));
	}

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}