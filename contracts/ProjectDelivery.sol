pragma solidity ^0.5.0;

import "./Pausable.sol";

contract ProjectDelivery is Pausable{
    
    address payable public manager;
    
    uint public projectCount;
    
    mapping (address => uint) pendingWithdrawals;
    
    mapping (uint => Project) public projects;
    mapping (address => Provider) public providers;
    mapping (address => Sponsor) public sponsors;
    mapping (address => Recipient) public recipients;
    mapping (address => Monitor) public monitors;
    
    enum State {Proposed, Qualified, Denied, Accepted, Sponsored, UnderReview, Completed, Failed}
    
    struct Project {
        string name;
        State state;
        uint cost;
        uint funds;
        address recipient;
        address sponsor;
        address provider;
        address monitor;
    }
    
    struct Provider {
        string name;
        bool isQualified;
        mapping (uint => bool) projects;
    }
    
    struct Sponsor {
        string name;
        bool isQualified;
        mapping (uint => bool) projects;
    }
    
    struct Recipient {
        string name;
        bool isQualified;
        address monitor;
        uint project;
    }
    
    struct Monitor {
        string name;
        bool isQualified;
        mapping (uint => bool) projects;
    }
    
    event Proposed(uint projectId);
    event Qualified(uint projectId);
    event Denied(uint projectId);
    event Accepted(uint projectId);
    event Sponsored(uint projectId);
    event UnderReview(uint projectId);
    event Completed(uint projectId);
    event Failed(uint projectId);
    
    modifier isManager() {require (msg.sender == manager); _;}
    modifier verifyCaller (address _address) { require (msg.sender == _address); _;}
    modifier isProvider (address _address) { require (providers[_address].isQualified); _;}
    modifier isSponsor (address _address) { require (sponsors[_address].isQualified); _;}
    modifier isMonitor (address _address) { require (monitors[_address].isQualified); _;}
    modifier isRecipient (address _address) { require (recipients[_address].isQualified); _;}
    
    modifier isProjectProvider (uint _pid, address _address) { 
        require (projects[_pid].provider == _address && providers[_address].projects[_pid]); _;}
    modifier isProjectSponsor (uint _pid, address _address) { 
        require (projects[_pid].sponsor == _address && sponsors[_address].projects[_pid]); _;}
    modifier isProjectMonitor (uint _pid, address _address) { 
        require (projects[_pid].monitor == _address && monitors[_address].projects[_pid]); _;}
    modifier isProjectRecipient (uint _pid, address _address) { 
        require (projects[_pid].recipient == _address && recipients[_address].project == _pid); _;}
        
    modifier proposed(uint _pid) { require(projects[_pid].state == State.Proposed); _;}
    modifier qualified(uint _pid) { require(projects[_pid].state == State.Qualified); _;}
    modifier denied(uint _pid) { require(projects[_pid].state == State.Denied); _;}
    modifier accepted(uint _pid) { require(projects[_pid].state == State.Accepted); _;}
    modifier sponsored(uint _pid) { require(projects[_pid].state == State.Sponsored); _;}
    modifier underreview(uint _pid) { require(projects[_pid].state == State.UnderReview); _;}
    modifier completed(uint _pid) { require(projects[_pid].state == State.Completed); _;}
    modifier failed(uint _pid) { require(projects[_pid].state == State.Failed); _;}
    
    
    constructor() public {
        manager = msg.sender;
        projectCount = 1;
    }
    
    function qualifyRecipient(
            address _recipient,
            string memory _name, 
            bool _qualify)
        public
        payable
        isMonitor(msg.sender)
        returns(bool)
    {
        if (_qualify)
            require(!recipients[_recipient].isQualified, "Recipient is already qualified");
            recipients[_recipient].name = _name;
            recipients[_recipient].isQualified = _qualify;
            recipients[_recipient].monitor = msg.sender;
            return true;
        if (!_qualify)
            require(recipients[_recipient].isQualified, "Recipient is already disqualified");
            recipients[_recipient].isQualified = _qualify;
            return true;
    }
    
    function qualifyMonitor(
            address _monitor, 
            string memory _name, 
            bool _qualify)
        public
        payable
        isManager()
        returns(bool)
    {
        if (_qualify)
            require(!monitors[_monitor].isQualified, "Monitor is already qualified");
            monitors[_monitor].name = _name;
            monitors[_monitor].isQualified = _qualify;
            return true;
        if (!_qualify)
            require(monitors[_monitor].isQualified, "Monitor is already disqualified");
            monitors[_monitor].isQualified = _qualify;
            return true;
    }
    
    function qualifySponsor(
            address _sponsor, 
            string memory _name, 
            bool _qualify)
        public
        payable
        isManager()
        returns(bool)
    {
        if (_qualify)
            require(!sponsors[_sponsor].isQualified, "Sponsor is already qualified");
            sponsors[_sponsor].name = _name;
            sponsors[_sponsor].isQualified = _qualify;
            return true;
        if (!_qualify)
            require(sponsors[_sponsor].isQualified, "Sponsor is already disqualified");
            sponsors[_sponsor].isQualified = _qualify;
            return true;
    }
    
    function qualifyProvider(
            address _provider, 
            string memory _name, 
            bool _qualify)
        public
        payable
        isManager()
        returns(bool)
    {
        if (_qualify)
            require(!providers[_provider].isQualified, "Provider is already qualified");
            providers[_provider].name = _name;
            providers[_provider].isQualified = _qualify;
            return true;
        if (!_qualify)
            require(providers[_provider].isQualified, "Provider is already disqualified");
            providers[_provider].isQualified = _qualify;
            return true;
    }
    
    function proposeProject(
            string memory _name, 
            uint _bid,
            address _recipient
        ) 
        public
        isProvider(msg.sender)
        isRecipient(_recipient)
        returns(bool)
    {
        emit Proposed(projectCount);
        projects[projectCount] = Project({name: _name,
                                            cost: _bid,
                                            state: State.Proposed,
                                            provider: msg.sender,
                                            recipient: _recipient,
                                            monitor: recipients[_recipient].monitor,
                                            sponsor: address(0),
                                            funds: 0
        });
        providers[msg.sender].projects[projectCount]=true;
        projectCount = projectCount + 1;
        return true;
    }
    
    function qualifyProposal(uint pid, bool qualify) 
        public
        payable
        isMonitor(msg.sender)
        proposed(pid)
        returns(bool)
    {
        require(projects[pid].monitor == msg.sender, "You must be the proposed monitor to qualify the project");
        if (qualify)
            monitors[msg.sender].projects[pid]=true;
            projects[pid].state = State.Qualified;
            emit Qualified(pid);
        if (!qualify)
            projects[pid].state = State.Denied;
            emit Denied(pid);
        return true;
    }
    
    function acceptProposal(uint pid, bool accept)
        public
        isRecipient(msg.sender)
        qualified(pid)
        returns(bool)
    {
        require(projects[pid].recipient == msg.sender, "You must be the proposed recipient to accept the project");
        require(recipients[msg.sender].project == 0, "You are only allowed to receive one project at a time");
        if (accept)
            recipients[msg.sender].project = pid;
            projects[pid].state = State.Accepted;
            emit Accepted(pid);
        if (!accept)
            projects[pid].state = State.Denied;
            emit Denied(pid);
        return true;
    }
    
    function sponsorProject(uint pid)
        public
        payable
        whenNotPaused
        accepted(pid)
        isSponsor(msg.sender)
        returns(bool)
    {
        require(projects[pid].sponsor == address(0), "Project must be unsponsored");
        require(projects[pid].cost == msg.value, "Must sponsor 100% of project cost");
        
        sponsors[msg.sender].projects[pid] = true;
        projects[pid].sponsor = msg.sender;
        projects[pid].state = State.Sponsored;
        projects[pid].funds = msg.value;
        emit Sponsored(pid);
        return true;
    }
    
    function requestReview(uint pid)
        public
        sponsored(pid)
        isProjectProvider(pid, msg.sender)
        returns(bool)
    {
        projects[pid].state = State.UnderReview;
        emit UnderReview(pid);
        return true;
    }
    
    function passFail(uint pid, bool pass, bool fixable)
        public
        whenNotPaused
        underreview(pid)
        isProjectMonitor(pid, msg.sender)
        returns(bool)
    {
        if (pass)
            projects[pid].state = State.Completed;
            pendingWithdrawals[projects[pid].provider] += projects[pid].funds;
            projects[pid].funds = 0;
            emit Completed(pid);
        if (!pass)
            if (fixable)
                projects[pid].state = State.Sponsored;
                emit Sponsored(pid);
            if (!fixable)
                projects[pid].state = State.Failed;
                pendingWithdrawals[projects[pid].sponsor] += projects[pid].funds;
                projects[pid].funds = 0;
                emit Failed(pid);
        return true;
    }
    
    function withdraw() public whenNotPaused {
        uint amount = pendingWithdrawals[msg.sender];
        // Remember to zero the pending refund before
        // sending to prevent re-entrancy attacks
        pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(amount);
    }
    
    
    function () external payable {
        revert();
    }
}