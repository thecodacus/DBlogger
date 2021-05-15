pragma solidity >=0.4.22 <0.9.0;
pragma experimental ABIEncoderV2;


contract DBlogger {
    // Defines a new type with two fields.

    enum Role {Admin, Editor, Author, Subscriber}

    struct User {
        bool isValue;
        address id;
        string name;
        string profile_hash;
        Role role;
    }

    struct Post {
        bool isValue;
        address author;
        string content_hash;
    }

    uint256 internal newPostCounter;
    mapping(uint256 => Post) posts;
    uint256[] postIndexs;
    address[] userIndexs;

    mapping(address => User) users;

    /**************************** Constructor **************************/
    constructor() public {
        userIndexs.push(msg.sender);
        users[msg.sender] = User({
            isValue: true,
            id: msg.sender,
            name: "Admin",
            profile_hash: "",
            role: Role.Admin
        });
    }

    /**************************** Modifiers ****************************/

    modifier onlyGuest() {
        if (!users[msg.sender].isValue) {
            _;
        }
    }

    modifier onlyUserOrAbove() {
        if (users[msg.sender].isValue) {
            _;
        }
    }

    modifier onlyAuthorOrAbove() {
        User memory user = users[msg.sender];
        if (user.isValue) {
            if (
                user.role == Role.Author ||
                user.role == Role.Editor ||
                user.role == Role.Admin
            ) {
                _;
            }
        }
    }

    modifier onlySelfOrAdmin(address id) {
        User memory user = users[msg.sender];
        if (user.isValue) {
            if (msg.sender == id || user.role == Role.Admin) {
                _;
            }
        }
    }
    modifier onlyAdmin() {
        User memory user = users[msg.sender];
        if (user.isValue) {
            if (user.role == Role.Admin) {
                _;
            }
        }
    }

    /**************************** Public Methods ***********************/

    /************* Insert Operations ***********/

    function addPost(
        string calldata _content_hash
    ) external onlyAuthorOrAbove returns (uint256 postID) {
        postID = newPostCounter++; // campaignID is return variable
        // Creates new struct and saves in storage. We leave out the mapping type.
        postIndexs.push(postID);
        posts[postID] = Post({
            isValue: true,
            author: users[msg.sender].id,
            content_hash:_content_hash
        });
    }

    function registerUser(string calldata _name, string calldata _profile_hash)
        external
        onlyGuest
    {
        userIndexs.push(msg.sender);
        users[msg.sender] = User({
            isValue: true,
            id: msg.sender,
            name: _name,
            profile_hash: _profile_hash,
            role: Role.Subscriber
        });
    }

    function makeAdmin(address id) external onlyAdmin {
        require(users[id].isValue, "User Not Registered");
        users[id].role = Role.Admin;
    }

    /************* Update Operations ***********/

    function editPost(
        uint256 postID,
        string calldata _content_hash
    ) external onlyAuthorOrAbove {
        require(posts[postID].isValue, "Post does not exist");
        require(
            (posts[postID].author == msg.sender ||
                users[msg.sender].role != Role.Author),
            "Only Author of the post or an Editor/Admin can edit posts"
        );
        posts[postID].content_hash = _content_hash;
    }

    function editUser(string calldata _name, string calldata _profile_hash)
        external
        onlyUserOrAbove
    {
        users[msg.sender].name = _name;
        users[msg.sender].profile_hash = _profile_hash;
    }

    function editUserRole(address id, Role _role) external onlyAdmin {
        require(users[id].isValue == false, "User not registered");
        if (users[id].role == Role.Admin) {
            require(
                id == msg.sender,
                "You dont have permission to perform the action"
            );
        }
        users[id].role = _role;
    }

    /************* Delete Operations ***********/

    function deletePost(uint256 postID) external onlyAuthorOrAbove {
        require(posts[postID].isValue, "Post does not exist");
        Post memory post = posts[postID];
        User memory sender = users[msg.sender];
        require(
            (post.author == msg.sender || sender.role != Role.Author),
            "Only Author of the post or an Editor/Admin can edit posts"
        );
        delete posts[postID];
        // uint256 index = postIndexs.length;
        // for (uint256 i = 0; i < postIndexs.length - 1; i++) {
        //     if (postIndexs[i] == postID) index = i;
        //     if (index < postIndexs.length - 1) {
        //         postIndexs[i] = postIndexs[i + 1];
        //     }
        // }
        // if (index < postIndexs.length) {
        //     delete postIndexs[postIndexs.length - 1];
        // }
        // postIndexs.pop();
    }

    function deleteUser(address id) public {
        require(
            id == msg.sender || users[msg.sender].role == Role.Admin,
            "You dont have permission to perform the action"
        );
        if (users[msg.sender].role == Role.Admin) {
            require(
                id == msg.sender,
                "You dont have permission to perform the action"
            );
        }
        User memory user = users[id];
        require(user.isValue, "user does not exist");
        delete users[id];
        // uint256 index = userIndexs.length;
        // for (uint256 i = 0; i < userIndexs.length - 1; i++) {
        //     if (userIndexs[i] == id) index = i;
        //     if (index < postIndexs.length - 1) {
        //         userIndexs[i] = userIndexs[i + 1];
        //     }
        // }
        // if (index < userIndexs.length) {
        //     delete userIndexs[userIndexs.length - 1];
        // }
        // userIndexs.pop();
    }

    /************* View Operations ***********/
    function getMyProfile() public view returns (User memory user) {
        require(users[msg.sender].isValue, "User not registered");
        user = users[msg.sender];
        return user;
    }

    function getUser(address id) public view returns (User memory) {
        return (users[id]);
    }

    function getAllUser() public view returns (User[] memory, uint256 count) {
        User[] memory userList = new User[](userIndexs.length);
        for (uint256 i = 0; i < userIndexs.length; i++) {
            userList[i] = users[userIndexs[i]];
        }
        return (userList, userIndexs.length);
    }

    function getPost(uint256 postID) public view returns (Post memory) {
        return posts[postID];
    }

    function getAllPost()
        public
        view
        returns (Post[] memory, uint256[] memory)
    {
        Post[] memory postList = new Post[](postIndexs.length);
        uint256[] memory Ids = new uint256[](postIndexs.length);
        for (uint256 i = 0; i < postIndexs.length; i++) {
            postList[i] = posts[postIndexs[i]];
            Ids[i] = postIndexs[i];
        }
        return (postList, Ids);
    }

    function getAllPostAuthor(address id, uint256 startIndex)
        public
        view
        returns (Post[100] memory, uint256 nextIndex)
    {
        require(users[id].isValue, "User does not exist");

        Post[100] memory postList;
        nextIndex = 0;
        uint256 count = 0;
        if (startIndex >= postIndexs.length) return (postList, nextIndex);
        for (uint256 i = 0; i < postIndexs.length; i++) {
            if (i >= startIndex && posts[postIndexs[i]].author == id) {
                postList[i] = posts[postIndexs[i]];
                count++;
            }
            nextIndex = i;
            if (count >= 100) break;
        }
        nextIndex++;
        if (nextIndex >= postIndexs.length) nextIndex = 0;
        return (postList, nextIndex);
    }

    /*************************** Enum to String *******************************/
    function getRoleName(Role role) public pure returns (string memory) {
        if (role == Role.Admin) return "Admin";
        if (role == Role.Editor) return "Editor";
        if (role == Role.Author) return "Author";
        if (role == Role.Subscriber) return "Subscriber";
    }
}
