pragma solidity >=0.4.0 <0.6.0;
pragma experimental ABIEncoderV2;
//Land Details
contract landReg{
    
    struct landDetails{
        
        //property Details set by admin
        string state;
        string district;
        string village;
        string surveyNumber;
        address CurrentOwner;
        
        //fields for making it sale 
        uint marketValue;       //set by Admin
        bool isAvailable;       //set by owner
        uint priceByOwner;      //set by owner
        
        address requester;      
        uint priceByRequester;
        enumReqStatus requestStatus;
        enumReqStatusByAdmin requestStatusByAdmin;
        
    }
    address owner;
    //request status
    enum enumReqStatus {Default,pending,reject,approved}
    enum enumReqStatusByAdmin {Default,pending,reject,approved}
    mapping(string => landDetails) land;                    //map surveyNumber to landDetails 
    mapping(string => landDetails[]) history;               //map surveyNumber to landDetails 
    mapping(string => address) Admin;                       //map village to Admin 
    
    
    
    
    //contract owner
    constructor() public{
        owner = msg.sender;
    }
    
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    //adding village admins
    function addAdmin(address _Admin,string memory _village )  public {
        require(owner==msg.sender);
        Admin[_village]=_Admin;
    }
    
    function getAdmin(string memory _village) public view returns (address) {
        return Admin[_village];
    }
    
    function Registration(string memory _state,string memory _district,
        string memory _village,string memory _surveyNumber,
        address _OwnerAddress,uint _marketValue
        ) public returns(bool) {
        // require(Admin[_village] == msg.sender);
        
        landDetails memory l;//=landDetails(_state,_district,_village,_surveyNumber,_OwnerAddress,_marketValue);
        l.state = _state;
        l.district = _district;
        l.village = _village;
        l.surveyNumber = _surveyNumber;
        l.CurrentOwner = _OwnerAddress;
        l.marketValue = _marketValue;
        
        land[_surveyNumber]=l;
        
        return true;
    }
   
    
    //to view details of land for everyone
    function viewLandDetails(string memory _surveyNumber) public view returns(address,string memory,string memory,string memory,bool,uint){
        return(land[_surveyNumber].CurrentOwner,land[_surveyNumber].state,land[_surveyNumber].district,land[_surveyNumber].village,land[_surveyNumber].isAvailable,land[_surveyNumber].priceByOwner);
    }
    //push a request to the land owner
    function requstToLandOwner(string memory _surveyNumber) public {
        require(land[_surveyNumber].isAvailable);
        land[_surveyNumber].requester=msg.sender;
        land[_surveyNumber].isAvailable=false;
        land[_surveyNumber].requestStatus = enumReqStatus.pending; //changes the status to pending.
    }
    
    //viewing request for the lands
     function viewRequest(string memory _surveyNumber)public view returns(address,enumReqStatus,enumReqStatusByAdmin){
         require(land[_surveyNumber].CurrentOwner == msg.sender || Admin[land[_surveyNumber].village]==msg.sender);
        return(land[_surveyNumber].requester,land[_surveyNumber].requestStatus,land[_surveyNumber].requestStatusByAdmin);
    }
    
    //availing land for sale.
    function makeAvailable(string memory _surveyNumber ,uint _priceByOwner )public{
        require(land[_surveyNumber].CurrentOwner == msg.sender);
        land[_surveyNumber].isAvailable=true;
        land[_surveyNumber].priceByOwner=_priceByOwner;
    } 
    
    //processing request for the land by accepting or rejecting
    function processRequestApprovedByOwner(string memory _surveyNumber,enumReqStatus status)public {
        require(land[_surveyNumber].CurrentOwner == msg.sender);
        land[_surveyNumber].requestStatus=status;
        if(status == enumReqStatus.reject){
            land[_surveyNumber].requester = address(0);
            land[_surveyNumber].requestStatus = enumReqStatus.Default;
        }
    }
    
    function processRequestApprovedByAdmin(string memory _surveyNumber , enumReqStatusByAdmin  adminstatus) public {
        require(Admin[land[_surveyNumber].village] == msg.sender);
        // require(land[_surveyNumber].requestStatus==enumReqStatus.approved) 
        land[_surveyNumber].requestStatusByAdmin=adminstatus;
        if(adminstatus == enumReqStatusByAdmin.reject){
            land[_surveyNumber].requester = address(0);
            land[_surveyNumber].requestStatus = enumReqStatus.Default;
        }
    }
        
    //buying the approved property
    function buyProperty(string memory _surveyNumber)public {
        require(land[_surveyNumber].requestStatusByAdmin == enumReqStatusByAdmin.approved);
        // require(msg.value >= (land[_surveyNumber].marketValue+((land[_surveyNumber].marketValue)/10)));
        //.CurrentOwner.transfer(land[_surveyNumber].marketValue);
        // removeOwnership(land[_surveyNumber].CurrentOwner,_surveyNumber);
    
        history[_surveyNumber].push(clone(land[_surveyNumber]));
        land[_surveyNumber].CurrentOwner=msg.sender;
        land[_surveyNumber].isAvailable=false;
        land[_surveyNumber].requester = address(0);
        land[_surveyNumber].requestStatus = enumReqStatus.Default;
        land[_surveyNumber].requestStatusByAdmin = enumReqStatusByAdmin.Default;
        land[_surveyNumber].priceByOwner=0;
    }
    
    
    function clone(landDetails memory from) internal pure returns (landDetails memory) {
        return landDetails(
        from.state,
        from.district,
        from.village,
        from.surveyNumber,
        from.CurrentOwner,
    
        from.marketValue,      
        from.isAvailable,      
        from.priceByOwner,     
        
        from.requester,      
        from.priceByRequester,
        from.requestStatus,
        from.requestStatusByAdmin
    );
    }
    
    function previousHistory(string memory _surveyNumber)public view returns(landDetails[] memory) {
        return(history[_surveyNumber]);
    }
}

//Ganache 
//Contract Owner/ Super Admin -0xdde8bf82698524e606815eb2c5228272f7b82afd
//Admin sol-0x2b372ff79dbdb362237ba1e34e9e7eef948f6bab
//1000 owner - 0x09a1a3cbe3ed6f64ae33b1972fe6394b420c2c07
//1000 buyer - 0x1f23fb1f456914c7ee99d595bf47e6a43db3fcdb
 
    //Admin 	            0xca35b7d915458ef540ade6068dfe2f44e8fa733c
    //owner                 0x14723A09ACff6D2A60DcdF7aA4AFf308FDDC160C
    //buyer                 0x4B0897b0513fdC7C541B6d9D7E929C4e5364D2dB
    