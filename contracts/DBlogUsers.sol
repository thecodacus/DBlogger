pragma solidity >=0.4.21 <0.7.0;
pragma experimental ABIEncoderV2;


contract DBlogUsers {
    // Defines a new type with two fields.

    enum Role {Admin, Editor, Author, Subscriber}

    struct User {
        bool isValue;
        address id;
        string name;
        string bio;
        Role role;
        string avatar;
    }
}
