pragma solidity >=0.4.21 <0.7.0;
pragma experimental ABIEncoderV2;


contract DBloggerPosts {
    // Defines a new type with two fields.

    struct Post {
        bool isValue;
        string title;
        string body;
        address author;
        string image;
    }

    uint256 internal newPostCounter;
    mapping(uint256 => Post) posts;
    uint256[] postIndexs;

    function addPost(
        string calldata _title,
        string calldata _body,
        string calldata _image,
        address _author
    ) external returns (uint256 postID) {
        postID = newPostCounter++; // campaignID is return variable
        // Creates new struct and saves in storage. We leave out the mapping type.
        postIndexs.push(postID);
        posts[postID] = Post({
            isValue: true,
            title: _title,
            body: _body,
            author: _author,
            image: _image
        });
    }

    /************* Update Operations ***********/

    function editPost(
        uint256 postID,
        string calldata _title,
        string calldata _body,
        string calldata _image
    ) external {
        posts[postID].title = _title;
        posts[postID].body = _body;
        posts[postID].image = _image;
    }

    function editPostImage(uint256 postID, string calldata _image) external {
        posts[postID].image = _image;
    }
}
