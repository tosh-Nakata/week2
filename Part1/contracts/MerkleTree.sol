//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves

        //calculate number of  total hash components and prepare
        for (uint256 i = 0; i < 8; i++) {
            hashes.push(0);
        }
        for (uint256 i = 0; i < 13; i+=2) {
            hashes.push(PoseidonT3.poseidon([hashes[i], hashes[i+1]]));
        }
        root = hashes[14];
        
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        hashes[index] = hashedLeaf;
        uint256 k = 0;
         for (uint256 i = 0; i < 13; i+=2) {
            hashes[8+k] = PoseidonT3.poseidon([hashes[i], hashes[i+1]]);
            k += 1;
        }
        index += 1;
        root = hashes[14];
        return root;

    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {
        // [assignment] verify an inclusion proof and check that the proof root matches current root
        //三つの値でrootを再計算し、それを元々のrootと比較する
            //a?b?c?  3回の再計算が必要なはず！！
        if (verifyProof(a,b,c,input) && (input[0] == root)) {
            return true;
        } else {
            return false;
        }

        

        //outputrootは何処？？？

    }
}
