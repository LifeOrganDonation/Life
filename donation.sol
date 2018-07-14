pragma solidity^0.4.20;
pragma experimental ABIEncoderV2;

interface Life {
    function checkStatus(address _user) returns (bool);
    function addRecipiant(string _BG, int _id, string _email, int _rank);
    function addDonor(string _BG, int _id);
    function matchDonor() returns (bool);
    function checkRank(address _user) returns (bytes32);
}

contract Donate {
	struct request{
		bool matchedTemp;
		bool matchedFinal;
		uint id;
		uint rank;
		string hospitalName;
		address requestingHospital;
		string emailHospital;
		uint bloodType;
	}
	struct donor{
		bool matchedTemp;
		bool matchedFinal;
		uint id;
		address donorAddress;
		uint bloodType;// 1-A, 2-B, 3-AB, 4-O
	//	uint rhFactor; //1:+, 2:-
	}

	mapping (uint => request) recipientList; 
	mapping (uint => donor) donorList;    
	uint lastDonorID;
    uint lastRecipiantID;
    uint lastRank;
    
    constructor() {
        lastDonorID = 0;
        lastRecipiantID = 0;
        lastRank= 0;
    }
    
    function checkStatusDonor(uint _donorID) returns (bool) {
        return donorList[_donorID].matchedTemp;
    }
    
    function checkStatusRecipiant(uint _recipientID) returns (bool) {
        return recipientList[_recipientID].matchedTemp;
    }
    
    function checkRank(uint id) returns (bytes32) {
        require(recipientList[id].requestingHospital != address(0));
        if(recipientList[id].rank > 0) {
            bytes32 data = bytes32(recipientList[id].rank);
            return data;
        }
        else {
            return "you are already matched!";
        }
    }
    
    function addDonor(uint _bloodType) returns (uint) {
        lastDonorID++;
        require(msg.sender != address(0));
        donorList[lastDonorID].matchedTemp = false;
        donorList[lastDonorID].donorAddress = msg.sender;
        donorList[lastDonorID].bloodType = _bloodType;
//        matchRecipiant(donors[lastDonorID]);
        return lastDonorID;
    }

    function addRecipiant(uint _bloodType, string _emailHospital) returns (uint){
        lastRank++;
        lastRecipiantID++;
        require(msg.sender != address(0));  
        recipientList[lastRecipiantID].matchedTemp = false;
        recipientList[lastRecipiantID].emailHospital = _emailHospital;
        recipientList[lastRecipiantID].bloodType = _bloodType;
        recipientList[lastRecipiantID].requestingHospital = msg.sender;
        recipientList[lastRecipiantID].rank = lastRank;
//        matchDonor(recipiants[lastRecipiantID]);
        return lastRecipiantID;
    }

}
