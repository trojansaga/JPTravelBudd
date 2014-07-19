//
//  JPMapListViewController.m
//  TravelBudd
//
//  Created by MC on 2014. 6. 7..
//  Copyright (c) 2014년 MinChul Song. All rights reserved.
//

#import "JPMapListViewController.h"
#import "JPAppDelegate.h"

#import "MapRecord.h"
#import "JPMapViewController.h"

@interface JPMapListViewController ()

@end

@implementation JPMapListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        JPAppDelegate *appDelegate = (JPAppDelegate *)[[UIApplication sharedApplication] delegate];
        _managedObjectContext = [appDelegate managedObjectContext];
        
    } 
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    _fetchedResultsController = [self fetchedResultsController];
    self.title = @"Map Lists";
    
    
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
                                  initWithTitle:@"add"
                                  style:UIBarButtonItemStylePlain
                                  target:self
                                  action:@selector(addMap)];
    
    self.navigationItem.rightBarButtonItem = addButton;

    
  }

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
//    NSArray *arr =
//    [_fetchedResultsController fetchedObjects];
//    NSFetchRequest *req = [[NSFetchRequest alloc] initWithEntityName:@"MapRecord"];
//    NSArray *arr = [_managedObjectContext executeFetchRequest:req error:nil];
    
    
}

#pragma mark - Action

- (void) addMap {
    NSLog(@"add Map");
    JPMapViewController *mapViewcontroller = [[JPMapViewController alloc] initWithNibName:@"JPMapViewController" bundle:nil];
    [self.navigationController pushViewController:mapViewcontroller animated:YES];
    
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    id  sectionInfo =
    [[_fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
//    FailedBankInfo *info = [_fetchedResultsController objectAtIndexPath:indexPath];
//    cell.textLabel.text = info.name;
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@, %@",
//                                 info.city, info.state];
    
//    MapRecord *mapRecord = [_fetchedResultsController objectAtIndexPath:indexPath];
//    cell.textLabel.text = mapRecord.m_MapTitle;
//    cell.detailTextLabel.text = mapRecord.m_Owner;
    MapRecord *mapRecord = [_fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = mapRecord.m_MapTitle;
    cell.detailTextLabel.text = mapRecord.m_Owner;

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
//    MapRecord *mapRecord = [_fetchedResultsController objectAtIndexPath:indexPath];
//    cell.textLabel.text = mapRecord.m_MapTitle;
//    cell.detailTextLabel.text = mapRecord.m_Owner;
//    
//    NSLog(@"text = %@ , indexPath.row = %lu", mapRecord.m_MapTitle, indexPath.row);

    
    return cell;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [_managedObjectContext deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        NSError *error = nil;
        if (![_managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    FailedBankInfo *info = [_fetchedResultsController objectAtIndexPath:indexPath];
//    SMBankDetailViewController *detailViewController = [[SMBankDetailViewController alloc] initWithBankInfo:info];
//    [self.navigationController pushViewController:detailViewController animated:YES];
    JPMapViewController *mapViewController = [[JPMapViewController alloc] initWithNibName:@"JPMapViewController" bundle:nil];
    mapViewController.managedObjectContext = _managedObjectContext;
    
    
    mapViewController.mapRecord = [_fetchedResultsController objectAtIndexPath:indexPath];
    
    [self.navigationController pushViewController:mapViewController animated:YES];
}


#pragma mark - fetchedResultsController

- (NSFetchedResultsController *)fetchedResultsController {
    
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"MapRecord" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc]
                              initWithKey:@"m_MapTitle" ascending:NO];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:sort]];
    
    [fetchRequest setFetchBatchSize:10];
    
    NSFetchedResultsController *theFetchedResultsController =
    [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                        managedObjectContext:_managedObjectContext sectionNameKeyPath:nil
                                                   cacheName:@"Root"];
    self.fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    
    [_fetchedResultsController performFetch:nil];
    
    return _fetchedResultsController;
    
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller is about to start sending change notifications, so prepare the table view for updates.
    [_mapListTableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *tableView = _mapListTableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray
                                               arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray
                                               arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id )sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [_mapListTableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [_mapListTableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // The fetch controller has sent all current change notifications, so tell the table view to process all updates.
    [_mapListTableView endUpdates];
}


@end
