pragma solidity ^0.4.20;

contract Life{

	uint lastRank;
	uint lastDonorID;
	uint lastRecipientId;
	struct request{
		bool matchedTemp;
		bool matchedFinal;
		uint rank;
		uint bloodType;// 1-A, 2-B, 3-AB, 4-O
		string hospitalName;
		address requestingHospital;
		string emailHospital;
		uint matchIdD;
	}
	struct donor{
		bool matchedTemp;
		bool matchedFinal;
		address donorAddress;
		uint bloodType;// 1-A, 2-B, 3-AB, 4-O
		uint matchIdR;
	}

	mapping (uint => request) recipientList; 
	mapping (uint => donor) donorList;

	constructor() {
        lastDonorID = 0;
        lastRecipientId = 0;
        lastRank = 0;
    }

    function () payable{
    	if(msg.value>0){
    		msg.sender.transfer(msg.value);
    	}
    }

    function checkRank(uint id)  public returns (uint) {
        require(recipientList[id].requestingHospital != address(0));
        require(recipientList[id].requestingHospital == msg.sender);
        return recipientList[id].rank;
    }

	function getStatusRequest(uint _id) public returns(string){
		require(recipientList[_id].requestingHospital == msg.sender);
		if(recipientList[_id].matchedTemp){
			return "A match has been found. The donor will contact you shortly.";
		} else{
			return "Match not found.";
		}
	}

	function getStatusDonor(uint _id) public returns(string){
		require(donorList[_id].donorAddress == msg.sender);
		string result;
		if(donorList[_id].matchedTemp){
			return result=  recipientList[donorList[_id].matchIdR].emailHospital;
		}
		return "Match not found";
	}

	// Blood match basis: O(O) AB(all) A(A,O) B(B,O)
	function getMatchDonor(uint _bloodType) internal returns (uint){
		uint id = 0;
		bool matchFound;
		for(uint i=1; i<= lastRecipientId && !matchFound; i++){
			if(_bloodType == 1){
				if((recipientList[i].bloodType ==1 || recipientList[i].bloodType == 4) && !recipientList[i].matchedTemp){
					id = i;
					matchFound = true;
				}
			}
			else if(_bloodType == 2){
				if((recipientList[i].bloodType ==2 || recipientList[i].bloodType == 4) && !recipientList[i].matchedTemp){
					id = i;
					matchFound = true;
				}
			}
			else if(_bloodType == 3){
				if(!recipientList[i].matchedTemp){
					id = i;
					matchFound = true;
				}
			}
			else if(_bloodType == 4){
				if(recipientList[i].bloodType == 4 && !recipientList[i].matchedTemp){
					id = i;
					matchFound = true;
				}
			}
		}	
		if(matchFound){
			recipientList[id].matchedTemp = true;
			//recipientList[id].matchIdD = _id;
		}
		return id;
	}

	function getMatchForRecipient(uint _bloodType) internal returns (uint){
		uint id = 0;
		bool matchFound;
		for(uint i=1; i<= lastDonorID && !matchFound; i++){
			if(_bloodType == 1){
				if((donorList[i].bloodType ==1 || donorList[i].bloodType == 4) && !donorList[i].matchedTemp){
					id = i;
					matchFound = true;
				}
			}
			else if(_bloodType == 2){
				if((donorList[i].bloodType ==2 || donorList[i].bloodType == 4) && !donorList[i].matchedTemp){
					id = i;
					matchFound = true;
				}
			}
			else if(_bloodType == 3){
				if(!donorList[i].matchedTemp){
					id = i;
					matchFound = true;
				}
			}
			else if(_bloodType == 4){
				if(donorList[i].bloodType == 4 && !donorList[i].matchedTemp){
					id = i;
					matchFound = true;
				}
			}
		}
		if(matchFound){
			donorList[id].matchedTemp = true;
		}
		return id;
	}
	//movedownbyrankone()
	function pushUpRecipients(uint _id) internal{
		for(uint i= _id+1; i<= lastRecipientId; i++){
			if(!recipientList[i].matchedFinal){
				recipientList[i].rank--;
			}
		}
		lastRank--;
	}
	//rejectDonor to reject the match provided. The recipient maintains his rank, and the donor is back in the donor pool. 
	function rejectDonor(uint _idDonor){
		require(recipientList[donorList[_idDonor].matchIdR].requestingHospital == msg.sender);
		donorList[_idDonor].matchedTemp = false;
		recipientList[donorList[_idDonor].matchIdR].matchedTemp = false;
		recipientList[donorList[_idDonor].matchIdR].matchIdD = 0;
		donorList[_idDonor].matchIdR= 0;
	}

	//acceptDonor for the hospital to accept the match given. This results in final match for both caseid in recipientList and donor. 
	//Also it pushes everyones rank below the id of recipientList
	function acceptDonor(uint _idDonor){
		uint matchedReceipient = donorList[_idDonor].matchIdR;
		require(recipientList[matchedReceipient].requestingHospital == msg.sender);
		donorList[_idDonor].matchedFinal = true;
		recipientList[matchedReceipient].matchedFinal = true;
		pushUpRecipients(matchedReceipient);
	}

	function addDonor(uint _bloodType) returns (uint) {
        lastDonorID++;
        require(msg.sender != address(0));
        donorList[lastDonorID].donorAddress = msg.sender;
        donorList[lastDonorID].bloodType = _bloodType;
		uint matchedRecipient = getMatchDonor(_bloodType);
		if(matchedRecipient>0){
			donorList[lastDonorID].matchIdR = matchedRecipient;
			recipientList[matchedRecipient].matchIdD = lastDonorID;
			donorList[lastDonorID].matchedTemp = true;
		}
		emit donorAddedd(lastDonorID);
	    return lastDonorID;
	}

    function addRecipiant(uint _bloodType, string _hospitalName, string _emailHospital) returns (uint){
        lastRank++;
        lastRecipientId++;
        require(msg.sender != address(0));  
        recipientList[lastRecipientId].hospitalName = _hospitalName;
        recipientList[lastRecipientId].emailHospital = _emailHospital;
        recipientList[lastRecipientId].bloodType = _bloodType;
        recipientList[lastRecipientId].requestingHospital = msg.sender;
        recipientList[lastRecipientId].rank = lastRank;
        uint matchedDonor = getMatchForRecipient(_bloodType);
        if(matchedDonor>0){
			recipientList[lastRecipientId].matchIdD = matchedDonor;
			donorList[matchedDonor].matchIdR = lastRecipientId;
			recipientList[lastRecipientId].matchedTemp = true;
		}
		emit recipientAdded(lastRecipientId, lastRank);

        return lastRecipientId;
    }

    event donorAddedd(uint _idDonor);
    event recipientAdded(uint _idRecipient, uint _rank);

}
