pragma solidity ^0.4.20;

contract Life{

	struct request{
		bool matchedTemp;
		bool matchedFinal;
		uint id;
		uint rank;
		string hospitalName;
		address requestingHospital;
		string emailHospital;
	}
	struct donor{
		bool matchedTemp;
		bool matchedFinal;
		uint id;
		address donorAddress;
		uint bloodType;// 1-A, 2-B, 3-AB, 4-O
		uint rhFactor; //1:+, 2:-
	}

	mapping (uint => request) recipientList; 
	mapping (uint => donor) donorList;

	function getStatusRequest(uint _id) public returns(bool){
		require(recipientList[_id].requestingHospital == msg.sender);
		return recipientList[_id].matched;
	}

	function getStatusDonor(uint _id) public returns(bool){
		require(donorList[_id].donorAddress == msg.sender);
		return donorList[_id].matched;
	}

	// Blood match basis: O(O) AB(all) A(A,O) B(B,O)
	function getMatchDonor(uint _bloodType) internal returns (uint){
		uint id = 0;
		bool matchFound;
		for(uint i=1; i<= recipientList.length && !matchFound; i++){
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
		}
		return id;
	}

	function getMatchForRecipient(uint _bloodType) internal returns (uint){
		for(uint i=1; i<= donorList.length && !matchFound; i++){
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
	function pushUpRecipient(uint _id) internal{
		for(uint i= _id+1; i<=recipientList; i++){
			if(!recipientList[i].matchedFinal){
				recipientList[i].rank--;
			}
		}
	}

	function rejectDonor(){
		
	}
}
