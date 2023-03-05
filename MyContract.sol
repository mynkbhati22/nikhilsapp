// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract OriginsNFTMarketplace is Pausable, ReentrancyGuard {
    address public owner;
    uint256 public platformFee; // 250 ~ 2.5%
    uint256 public maxRoyaltyFee = 750; // 750 ~ 7.5%

    IERC20 public USDT;

    struct Collection {
        uint256 collectionId;
        address creator;
        uint256 royaltyFee; // 750 ~ 7.5%
        address walletForRoyalty;
        mapping(address => mapping(uint256 => NFTListing)) nftsListed;
    }

    struct NFTListing {
        uint256 listingId;
        address NFTContractAddress;
        address seller;
        bool NFTStandard; // true for ERC721, false for ERC1155
        uint256 TokenId;
        uint256 QuantityOnSale;
        uint256 PricePerNFT;
        uint256 listingExpireTime;
        uint256 listingStatus; // 0 = inactive, 1 = active, 2 = sold
        uint256[] offers;
    }

    struct Offer {
        uint256 offerId;
        address NFTContractAddress;
        uint256 collectionId;
        uint256 TokenId;
        uint256 quantityOfferedForPurchase;
        uint256 pricePerNFT;
        uint256 offerExpireTime;
        address offerCreator;
        bool isActive;
        uint256 lockedValue; // value locked into the contract
    }

    mapping(uint256 => Collection) public collections;
    mapping(uint256 => NFTListing) public NFTListings;
    mapping(uint256 => Offer) public offers;
    mapping(uint256 => mapping(uint256 => uint256)) private _offersByListing;
    uint256 public collectionIdCounter;
    uint256 public listingIdCounter;
    uint256 public offerIdCounter;

    event CollectionCreated(
        uint256 collectionId,
        uint256 royaltyFee,
        address walletForRoyalty
    );

    event CollectionEdited(
        uint256 collectionId,
        uint256 royaltyFee,
        address walletForRoyalty
    );
    event NFTListed(
        uint256 collectionId,
        uint256 listingId,
        address NFTContractAddress,
        bool NFTStandard,
        uint256 TokenId,
        uint256 QuantityOnSale,
        uint256 PricePerNFT,
        uint256 listingExpireTime
    );
    event ListingUpdated(
        uint256 collectionId,
        uint256 listingId,
        address NFTContractAddress,
        uint256 TokenId,
        uint256 QuantityOnSale,
        uint256 PricePerNFT,
        uint256 listingExpireTime
    );
    event ListingStatusUpdated(uint256 statusCode);
    event OfferCreated(
        uint256 offerId,
        uint256 collectionId,
        uint256 TokenId,
        uint256 quantityOfferedForPurchase,
        uint256 pricePerNFT,
        uint256 offerExpireTime
    );
    event OfferModified(
        uint256 offerId,
        uint256 quantityOfferedForPurchase,
        uint256 pricePerNFT,
        uint256 offerExpireTime
    );
    event OfferCancelled(uint256 offerId);
    event OfferAccepted(uint256 offerId, address buyer);
    event NFTBought(uint256 listingId, address buyer);
    event TokenRecovery(address indexed tokenAddress, uint256 indexed amount);
    event NFTRecovery(
        address indexed collectionAddress,
        uint256 indexed tokenId
    );
    event Pause(string reason);
    event Unpause(string reason);

    constructor(uint256 _platformFee, IERC20 _USDT) {
        owner = msg.sender;
        platformFee = _platformFee;
        USDT = _USDT;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    // All getter funcions
    /**
    ----------------------------------------------------------------------------
    **/

    function getCollectionsByCreator(address _creator)
        external
        view
        returns (uint256[] memory)
    {
        uint256 count = 0;
        for (uint256 i = 1; i <= collectionIdCounter; i++) {
            if (collections[i].creator == _creator) {
                count++;
            }
        }
        uint256[] memory result = new uint256[](count);
        uint256 index = 0;
        for (uint256 i = 1; i <= collectionIdCounter; i++) {
            if (collections[i].creator == _creator) {
                result[index] = i;
                index++;
            }
        }
        return result;
    }

    // function getNFTListingByToken(address _NFTContractAddress, uint256 _TokenId)
    //     external
    //     view
    //     returns (NFTListing memory)
    // {
    //     for (uint256 i = 0; i < collectionIdCounter; i++) {
    //         Collection storage collection = collections[i];
    //         if (collection.creator != address(0)) {
    //             for (uint256 j = 1; j <= listingIdCounter; j++) {
    //                 NFTListing storage listing = collection.nftsListed[
    //                     NFTListings[j].NFTContractAddress
    //                 ][NFTListings[j].TokenId];
    //                 if (
    //                     listing.listingId != 0 &&
    //                     listing.NFTContractAddress == _NFTContractAddress &&
    //                     listing.TokenId == _TokenId
    //                 ) {
    //                     return listing;
    //                 }
    //             }
    //         }
    //     }
    //     revert("Listing not found");
    // }

    function getNFTListingByToken(address _NFTContractAddress, uint256 _TokenId)
        external
        view
        returns (NFTListing memory)
    {
        for (uint256 i = 1; i <= collectionIdCounter; i++) {
            Collection storage collection = collections[i];
            if (collection.creator != address(0)) {
                for (uint256 j = 1; j <= listingIdCounter; j++) {
                    NFTListing storage listing = collection.nftsListed[
                        NFTListings[j].NFTContractAddress
                    ][NFTListings[j].TokenId];
                    if (
                        listing.listingId != 0 &&
                        listing.NFTContractAddress == _NFTContractAddress &&
                        listing.TokenId == _TokenId
                    ) {
                        return listing;
                    }
                }
            }
        }
        revert("Listing not found");
    }

    function getNFTListingsByUser(address user)
        external
        view
        returns (NFTListing[] memory)
    {
        uint256 count = 0;
        for (uint256 i = 1; i <= collectionIdCounter; i++) {
            Collection storage collection = collections[i];
            if (collection.creator != address(0)) {
                for (uint256 j = 1; j <= listingIdCounter; j++) {
                    NFTListing storage listing = collection.nftsListed[
                        NFTListings[j].NFTContractAddress
                    ][NFTListings[j].TokenId];
                    if (listing.listingId != 0 && listing.seller == user) {
                        count++;
                    }
                }
            }
        }
        NFTListing[] memory result = new NFTListing[](count);
        uint256 index = 0;
        for (uint256 i = 1; i <= collectionIdCounter; i++) {
            Collection storage collection = collections[i];
            if (collection.creator != address(0)) {
                for (uint256 j = 1; j <= listingIdCounter; j++) {
                    NFTListing storage listing = collection.nftsListed[
                        NFTListings[j].NFTContractAddress
                    ][NFTListings[j].TokenId];
                    if (listing.listingId != 0 && listing.seller == user) {
                        result[index] = listing;
                        index++;
                    }
                }
            }
        }
        return result;
    }

    function getOffersByListedNFT(uint256 _listingId)
        external
        view
        returns (uint256[] memory)
    {
        NFTListing storage listing = NFTListings[_listingId];

        return listing.offers;
    }

    function getOffersByCreator(address _offerCreator)
        external
        view
        returns (Offer[] memory)
    {
        uint256 count = 0;
        for (uint256 i = 1; i <= offerIdCounter; i++) {
            if (offers[i].offerCreator == _offerCreator) {
                count++;
            }
        }
        Offer[] memory result = new Offer[](count);
        uint256 index = 0;
        for (uint256 i = 1; i <= offerIdCounter; i++) {
            Offer storage offer = offers[i];
            if (offer.offerCreator == _offerCreator) {
                result[index] = offer;
                index++;
            }
        }
        return result;
    }

    function getOffersByListingId(uint256 _listingId)
        external
        view
        returns (Offer[] memory)
    {
        uint256 count = 0;
        for (uint256 i = 1; i <= offerIdCounter; i++) {
            if (
                offers[i].isActive &&
                offers[i].NFTContractAddress ==
                NFTListings[_listingId].NFTContractAddress &&
                offers[i].TokenId == NFTListings[_listingId].TokenId
            ) {
                count++;
            }
        }
        Offer[] memory result = new Offer[](count);
        uint256 index = 0;
        for (uint256 i = 1; i <= offerIdCounter; i++) {
            if (
                offers[i].isActive &&
                offers[i].NFTContractAddress ==
                NFTListings[_listingId].NFTContractAddress &&
                offers[i].TokenId == NFTListings[_listingId].TokenId
            ) {
                result[index] = offers[i];
                index++;
            }
        }
        return result;
    }

    // All getter funcions
    /**
    ----------------------------------------------------------------------------
    **/

    function addCollection(uint256 royaltyFee, address walletForRoyalty)
        external
    {
        require(
            walletForRoyalty != address(0),
            "Invalid royalty wallet address"
        );
        require(
            royaltyFee <= maxRoyaltyFee,
            "Royalty fee percentage is too high"
        );
        require(msg.sender != address(0), "Invalid caller address");

        // Increment the collection ID counter
        collectionIdCounter++;

        // Create a new Collection struct and store it in the collections mapping
        Collection storage newCollection = collections[collectionIdCounter];
        newCollection.collectionId = collectionIdCounter;
        newCollection.creator = msg.sender;
        newCollection.royaltyFee = royaltyFee;
        newCollection.walletForRoyalty = walletForRoyalty;

        // Emit an event to notify clients
        emit CollectionCreated(
            collectionIdCounter,
            royaltyFee,
            walletForRoyalty
        );
    }

    function editCollection(
        uint256 collectionId,
        uint256 royaltyFee,
        address walletForRoyalty
    ) external {
        require(
            collections[collectionId].creator != address(0),
            "Collection does not exist"
        );

        require(
            collections[collectionId].creator == msg.sender,
            "Only collection owner can edit the collection"
        );

        require(
            royaltyFee <= maxRoyaltyFee,
            "Royalty fee percentage exceeds the maximum allowed"
        );

        collections[collectionId].royaltyFee = royaltyFee;
        collections[collectionId].walletForRoyalty = walletForRoyalty;

        emit CollectionEdited(collectionId, royaltyFee, walletForRoyalty);
    }

    function listNFT(
        uint256 _collectionId,
        address _nftContractAddress,
        bool _nftStandard,
        uint256 _tokenId,
        uint256 _quantityOnSale,
        uint256 _pricePerNFT,
        uint256 _listingExpireTime
    ) external nonReentrant whenNotPaused {
        require(_quantityOnSale > 0, "Quantity must be greater than 0");
        require(_pricePerNFT > 0, "Price per NFT must be greater than 0");

        // Ensure that the specified collection exists
        require(
            collections[_collectionId].creator != address(0),
            "Collection does not exist"
        );

        // Ensure that the specified NFT exists and is of the correct type
        if (_nftStandard) {
            require(
                IERC721(_nftContractAddress).ownerOf(_tokenId) == msg.sender,
                "You must be the owner of the NFT"
            );
        } else {
            require(
                IERC1155(_nftContractAddress).balanceOf(msg.sender, _tokenId) >=
                    _quantityOnSale,
                "You do not own enough NFTs"
            );
        }

        // Check if NFT is already listed
        bool isAlreadyListed = false;
        for (uint256 i = 1; i <= collectionIdCounter; i++) {
            Collection storage collection = collections[i];
            if (collection.creator != address(0)) {
                for (uint256 j = 1; j <= listingIdCounter; j++) {
                    NFTListing storage list = collection.nftsListed[
                        NFTListings[j].NFTContractAddress
                    ][NFTListings[j].TokenId];
                    if (
                        list.NFTContractAddress == _nftContractAddress &&
                        list.TokenId == _tokenId
                    ) {
                        isAlreadyListed = true;
                        break;
                    }
                }
            }
        }

        require(!isAlreadyListed, "NFT is already listed");

        // Create a new listing and update the NFT's mapping in the collection
        listingIdCounter++;
        NFTListing storage listing = NFTListings[listingIdCounter];
        listing.listingId = listingIdCounter;
        listing.NFTContractAddress = _nftContractAddress;
        listing.seller = msg.sender;
        listing.NFTStandard = _nftStandard;
        listing.TokenId = _tokenId;
        listing.QuantityOnSale = _quantityOnSale;
        listing.PricePerNFT = _pricePerNFT;
        listing.listingExpireTime = _listingExpireTime;
        listing.listingStatus = 1;
        collections[_collectionId].nftsListed[_nftContractAddress][
            _tokenId
        ] = listing;

        // Emit the NFTListed event
        emit NFTListed(
            _collectionId,
            listingIdCounter,
            _nftContractAddress,
            _nftStandard,
            _tokenId,
            _quantityOnSale,
            _pricePerNFT,
            _listingExpireTime
        );
    }

    function toggleListing(
        uint256 _collectionId,
        uint256 _listingId,
        uint256 _tokenId,
        uint256 statusCode
    ) external nonReentrant {
        Collection storage collection = collections[_collectionId];
        NFTListing storage listing = collection.nftsListed[NFTListings[_listingId].NFTContractAddress][_tokenId];

        require(listing.NFTContractAddress != address(0), "Listing not found");
        require(
            IERC1155(listing.NFTContractAddress).balanceOf(
                msg.sender,
                listing.TokenId
            ) >=
                listing.QuantityOnSale ||
                msg.sender ==
                IERC721(listing.NFTContractAddress).ownerOf(listing.TokenId),
            "Only the listing owner can cancel listing"
        );
        require(statusCode < 2, "Can't set sold mode with this function!");

        listing.listingStatus = statusCode;

        emit ListingStatusUpdated(statusCode);
    }

    function updateListing(
        uint256 _collectionId,
        uint256 _listingId,
        uint256 _tokenId,
        uint256 _quantityOnSale,
        uint256 _pricePerNFT,
        uint256 _listingExpireTime
    ) external nonReentrant {
        Collection storage collection = collections[_collectionId];
        NFTListing storage listing = collection.nftsListed[NFTListings[_listingId].NFTContractAddress][_tokenId];

        require(listing.NFTContractAddress != address(0), "Listing not found");
        require(
            IERC1155(listing.NFTContractAddress).balanceOf(
                msg.sender,
                listing.TokenId
            ) >=
                listing.QuantityOnSale ||
                msg.sender ==
                IERC721(listing.NFTContractAddress).ownerOf(listing.TokenId),
            "Only the listing owner can cancel listing"
        );

        listing.QuantityOnSale = _quantityOnSale;
        listing.PricePerNFT = _pricePerNFT;
        listing.listingExpireTime = _listingExpireTime;
        listing.listingStatus = 1;

        emit ListingUpdated(
            _collectionId,
            _listingId,
            listing.NFTContractAddress,
            listing.TokenId,
            _quantityOnSale,
            _pricePerNFT,
            _listingExpireTime
        );
    }

    function buyNFT(
        uint256 _collectionId,
        uint256 _listingId,
        uint256 _tokenId,
        uint256 _quantity
    ) external nonReentrant whenNotPaused {
        require(
            NFTListings[_listingId].listingExpireTime > block.timestamp,
            "Listing has expired"
        );
        require(
            NFTListings[_listingId].QuantityOnSale >= _quantity,
            "Not enough NFTs for sale"
        );
        require(
            NFTListings[_listingId].PricePerNFT * _quantity <=
                USDT.balanceOf(msg.sender),
            "You don't have enough balance"
        );
        Collection storage collection = collections[_collectionId];
        NFTListing storage listing = collection.nftsListed[NFTListings[_listingId].NFTContractAddress][_tokenId];
        require(
            msg.sender !=
                IERC721(listing.NFTContractAddress).ownerOf(listing.TokenId),
            "Owner can't buy own listings"
        );
        require(msg.sender != listing.seller, "Seller can't buy own listing!");
        require(
            listing.QuantityOnSale >= _quantity,
            "Not enough NFTs for sale"
        );
        require(
            listing.listingExpireTime > block.timestamp,
            "Listing has expired"
        );
        require(
            listing.listingStatus == 1,
            "Can't buy inactive or already sold listing"
        );

        uint256 totalPrice = NFTListings[_listingId].PricePerNFT * _quantity;
        uint256 platfromFeeAmount = (NFTListings[_listingId].PricePerNFT *
            _quantity *
            platformFee) / 10000;
        uint256 royaltyFeeAmount = (NFTListings[_listingId].PricePerNFT *
            _quantity *
            collection.royaltyFee) / 10000;

        // Calculate remaining payment for seller
        uint256 paymentToSeller = totalPrice -
            platfromFeeAmount -
            royaltyFeeAmount;

        // Transfer USDT to contract
        USDT.transferFrom(msg.sender, address(this), totalPrice);

        // Handle platform fee
        if (platfromFeeAmount > 0) {
            USDT.transfer(owner, platfromFeeAmount);
        }

        // Handle royalty fee
        if (royaltyFeeAmount > 0) {
            USDT.transfer(collection.walletForRoyalty, royaltyFeeAmount);
        }

        // Transfer payment to seller
        address seller = listing.seller;
        require(
            USDT.transfer(seller, paymentToSeller),
            "Payment transfer failed"
        );

        // Transfer NFT to buyer
        if (listing.NFTStandard) {
            IERC721(listing.NFTContractAddress).safeTransferFrom(
                listing.seller,
                msg.sender,
                listing.TokenId
            );
            listing.seller = msg.sender;
        } else {
            IERC1155(listing.NFTContractAddress).safeTransferFrom(
                listing.seller,
                msg.sender,
                listing.TokenId,
                _quantity,
                ""
            );
        }

        // Update listing
        listing.QuantityOnSale -= _quantity;
        listing.listingStatus = 2;
        emit NFTBought(_listingId, msg.sender);
    }

    function createOffer(
        uint256 _collectionId,
        uint256 _listingId,
        uint256 _tokenId,
        uint256 _quantityOfferedForPurchase,
        uint256 _pricePerNFT,
        uint256 _offerExpireTime
    ) external nonReentrant {
        Collection storage collection = collections[_collectionId];
        NFTListing storage listing = collection.nftsListed[NFTListings[_listingId].NFTContractAddress][_tokenId];
        require(collection.collectionId == _collectionId, "Invalid Collection");
        // require(listing.listingId == _listingId, "Invalid Listing ID");
        require(listing.listingExpireTime > block.timestamp, "Listing expired");
        require(
            listing.QuantityOnSale >= _quantityOfferedForPurchase,
            "Quantity not available"
        );
        require(_offerExpireTime > block.timestamp, "Offer expired");

        uint256 lockedValue = _quantityOfferedForPurchase * _pricePerNFT;
        require(
            USDT.allowance(msg.sender, address(this)) >= lockedValue,
            "Insufficient allowance"
        );
        require(
            USDT.transferFrom(msg.sender, address(this), lockedValue),
            "USDT transfer failed"
        );

        offerIdCounter++;
        uint256 offerId = offerIdCounter;
        Offer storage offer = offers[offerId];
        offer.offerId = offerId;
        offer.NFTContractAddress = listing.NFTContractAddress;
        offer.collectionId = _collectionId;
        offer.TokenId = listing.TokenId;
        offer.quantityOfferedForPurchase = _quantityOfferedForPurchase;
        offer.pricePerNFT = _pricePerNFT;
        offer.offerExpireTime = _offerExpireTime;
        offer.offerCreator = msg.sender;
        offer.isActive = true;
        offer.lockedValue = lockedValue;

        _offersByListing[_collectionId][_listingId] = offerId;

        listing.offers.push(offerId);

        emit OfferCreated(
            offerId,
            _collectionId,
            listing.TokenId,
            _quantityOfferedForPurchase,
            _pricePerNFT,
            _offerExpireTime
        );
    }

    function cancelOffer(uint256 offerId) external nonReentrant {
        require(
            offers[offerId].offerCreator == msg.sender,
            "Only offer creator can cancel offer"
        );
        require(offers[offerId].isActive, "Offer is already inactive");
        require(
            offers[offerId].lockedValue > 0,
            "No amount locked for refund!"
        );

        offers[offerId].isActive = false;

        uint256 refundAmount = offers[offerId].lockedValue;

        USDT.transfer(offers[offerId].offerCreator, refundAmount);

        // Emit an event to notify clients
        emit OfferCancelled(offerId);
    }

    function modifyOffer(
        uint256 offerId,
        uint256 quantityOfferedForPurchase,
        uint256 pricePerNFT,
        uint256 offerExpireTime
    ) external nonReentrant {
        Offer storage offer = offers[offerId];
        require(
            offer.offerCreator == msg.sender,
            "Only offer creator can modify offer"
        );
        require(offer.isActive, "Offer is already inactive");
        require(
            offer.quantityOfferedForPurchase > 0,
            "Invalid quantity offered for purchase"
        );
        require(offer.pricePerNFT > 0, "Invalid price per NFT");
        require(
            offer.offerExpireTime > block.timestamp,
            "Invalid offer expiration time"
        );

        uint256 newLockedValue = offer.quantityOfferedForPurchase *
            offer.pricePerNFT;

        if (newLockedValue > offer.lockedValue) {
            require(
                USDT.balanceOf(msg.sender) >=
                    newLockedValue - offer.lockedValue,
                "Not enough balance in your wallet"
            );
            require(
                USDT.transferFrom(
                    msg.sender,
                    address(this),
                    newLockedValue - offer.lockedValue
                ),
                "USDT transfer failed"
            );
        } else {
            uint256 refundAmount = offer.lockedValue - newLockedValue;

            USDT.transfer(offer.offerCreator, refundAmount);
        }

        // Update offer details
        offer.quantityOfferedForPurchase = quantityOfferedForPurchase;
        offer.pricePerNFT = pricePerNFT;
        offer.offerExpireTime = offerExpireTime;
        offer.lockedValue = newLockedValue;

        // Emit an event to notify clients
        emit OfferModified(
            offerId,
            quantityOfferedForPurchase,
            pricePerNFT,
            offerExpireTime
        );
    }

    function acceptOffer(
        uint256 _listingId,
        uint256 _tokenId,
        uint256 _collectionId,
        uint256 _offerId
    ) external nonReentrant {
        // NFTListing storage listing = NFTListings[_listingId];
        Collection storage collection = collections[_collectionId];
        NFTListing storage listing = collection.nftsListed[NFTListings[_listingId].NFTContractAddress][_tokenId];
        Offer storage offer = offers[_offerId];
        require(
            listing.seller == msg.sender,
            "Only the seller can accept offers"
        );
        require(
            offer.offerCreator != listing.seller,
            "The seller cannot accept their own offer"
        );

        uint256 offerAmount = offer.quantityOfferedForPurchase *
            offer.pricePerNFT;
        require(
            offerAmount > 0,
            "No offer has been made for this listing and offerer"
        );

        // Calculate fees
        uint256 platformFeeAmount = (offerAmount * platformFee) / 10000;
        uint256 royaltyFeeAmount = (offerAmount * collection.royaltyFee) /
            10000;

        // Transfer funds to seller, platform fee to marketplace owner, and royalty fee to NFT creator
        address seller = listing.seller;
        address royaltyWallet = collection.walletForRoyalty;
        require(
            seller != address(0) && royaltyWallet != address(0),
            "Invalid seller or creator address"
        );

        USDT.transfer(
            seller,
            offerAmount - platformFeeAmount - royaltyFeeAmount
        );
        if (platformFeeAmount > 0) {
            USDT.transfer(owner, platformFeeAmount);
        }
        if (royaltyFeeAmount > 0) {
            USDT.transfer(collection.walletForRoyalty, royaltyFeeAmount);
        }

        // Transfer NFT to buyer
        if (listing.NFTStandard) {
            IERC721(listing.NFTContractAddress).safeTransferFrom(
                seller,
                offer.offerCreator,
                listing.TokenId
            );
            listing.seller = offer.offerCreator;
        } else {
            IERC1155(listing.NFTContractAddress).safeTransferFrom(
                seller,
                offer.offerCreator,
                offer.TokenId,
                offer.quantityOfferedForPurchase,
                ""
            );
        }

        // Update listing and offer statuses
        listing.listingStatus = 2;
        _offersByListing[_collectionId][_listingId] = 0;

        emit OfferAccepted(_offerId, offer.offerCreator);
    }

    /**
        Admin functions
        -------------------------------------------------------------------
    **/

    /** 
        @notice recover any ERC20 token sent to the contract
        @param _token address of the token to recover
        @param _amount amount of the token to recover
    */
    function recoverToken(address _token, uint256 _amount)
        external
        whenPaused
        onlyOwner
    {
        IERC20(_token).transfer(address(msg.sender), _amount);
        emit TokenRecovery(_token, _amount);
    }

    /** 
        @notice recover any ERC721 token sent to the contract
        @param _NFTContract of the collection to recover
        @param _tokenId uint256 of the tokenId to recover
    */
    function recoverNFT(address _NFTContract, uint256 _tokenId)
        external
        whenPaused
        onlyOwner
    {
        IERC721 nft = IERC721(_NFTContract);
        nft.safeTransferFrom(address(this), address(msg.sender), _tokenId);
        emit NFTRecovery(_NFTContract, _tokenId);
    }

    /** 
        @notice recover any ERC721 token sent to the contract
        @param _NFTContract of the collection to recover
        @param _tokenId uint256 of the tokenId to recover
    */
    function recover1155NFT(
        address _NFTContract,
        uint256 _tokenId,
        uint256 _quantity
    ) external whenPaused onlyOwner {
        IERC1155 nft = IERC1155(_NFTContract);
        nft.safeTransferFrom(
            address(this),
            address(msg.sender),
            _tokenId,
            _quantity,
            ""
        );
        emit NFTRecovery(_NFTContract, _tokenId);
    }

    /** 
        @notice pause the marketplace
        @param _reason string of the reason for pausing the marketplace
    */
    function pauseMarketplace(string calldata _reason)
        external
        whenNotPaused
        onlyOwner
    {
        _pause();
        emit Pause(_reason);
    }

    /** 
        @notice unpause the marketplace
        @param _reason string of the reason for unpausing the marketplace
    */
    function unpauseMarketplace(string calldata _reason)
        external
        whenPaused
        onlyOwner
    {
        _unpause();
        emit Unpause(_reason);
    }

    /**
        Admin functions
        -------------------------------------------------------------------
    **/
}
