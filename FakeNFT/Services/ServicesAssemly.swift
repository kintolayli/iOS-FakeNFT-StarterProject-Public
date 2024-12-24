final class ServicesAssembly {
    
    private let networkClient: NetworkClient
    private let nftStorage: NftStorage
    // private let myNftStorage: MyNftStorage
    //private let statisticStorage: StatisticStorage
    
    init(
        networkClient: NetworkClient,
        nftStorage: NftStorage
        // myNftStorage: MyNftStorage,
    ) {
        self.networkClient = networkClient
        self.nftStorage = nftStorage
        //self.myNftStorage = myNftStorage
    }
    
    var nftService: NftService {
        NftServiceImpl(
            networkClient: networkClient,
            storage: nftStorage
        )
    }
    
    var profileService: ProfileService {
        ProfileServiceImpl(networkClient: networkClient)
    }
}
