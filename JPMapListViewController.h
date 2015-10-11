//
//  JPMapListViewController.h
//  TravelBudd
//
//  Created by MC on 2014. 6. 7..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JPMapListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, NSFetchedResultsControllerDelegate> {
    UIActivityIndicatorView *indicator;


}

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong) IBOutlet UISearchBar *searchBar;
@property (nonatomic, strong) IBOutlet UITableView *mapListTableView;
//@property (nonatomic, strong) IBOutlet UICollectionView *collectionView;





@end
