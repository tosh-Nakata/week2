pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";
include "../node_modules/circomlib/circuits/mux1.circom";
template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    //the number of hash components used to hash the leaves
    var numLeafHashers = 2 ** (n-1);
    var i;
    //calculate number of  total hash components and prepare
    var numHashers = 0;
    for (i = 0; i < n; i++) {
        numHashers +=  2 ** i;
    }
    component hashers[numHashers];
    //initialize hashers
    for (i = 0; i < numHashers; i ++) {
        hashers[i]  = Poseidon(2);
    }
    //leaf hashes => high layer hash
    for (i = 0; i < 2**n; i ++) {
        hashers[i].inputs[0] <==  leaves[i * 2];
        hashers[i].inputs[1] <==  leaves[i * 2 + 1];
    }
    //calc root
    var k = 0;
    for (i = numLeafHashers; i < numHashers; i ++) {
        hashers[i].inputs[0] <== hashers[k*2].out;
        hashers[i].inputs[1] <== hashers[k*2 + 1].out;
        k ++;
    }
    root <== hashers[numHashers-1].out;


}
//特定のleaf（自分のtxn）がいることを証明したい！！
template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left0 or right1
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path
    component hashers[n];
    component mux[n];
    signal level_hashes[n+1];
    level_hashes[0] <==  leaf;

    for (var i = 0; i < n; i++){
        //mux right left arrange
        hashers[i] =  Poseidon(2);
        mux[i] =  MultiMux1(2);
        mux[i].c[0][0] <== level_hashes[i];
        mux[i].c[0][1] <== path_elements[i];
        mux[i].c[1][0] <== path_elements[i];
        mux[i].c[1][1] <== level_hashes[i];
        mux[i].s <==  path_index[i];
        hashers[i].inputs[0] <==  mux[i].out[0];
        hashers[i].inputs[1] <==  mux[i].out[1];

        level_hashes[i + 1] <==  hashers[i].out;


    }
    root <==  level_hashes[n];


}