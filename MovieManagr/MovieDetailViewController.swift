//
//  MovieDetailViewController.swift
//  MovieManagr
//
//  Created by Joseph Vallillo on 2/16/16.
//  Copyright © 2016 Joseph Vallillo. All rights reserved.
//

import UIKit

// MARK: - MovieDetailViewController: UIViewController

class MovieDetailViewController: UIViewController {
    
    // MARK: Properties
    
    var movie: TMDBMovie?
    var isFavorite = false
    var isWatchlist = false
    
    // MARK: Outlets
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var toggleFavoriteButton: UIBarButtonItem!
    @IBOutlet weak var toggleWatchlistButton: UIBarButtonItem!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController!.navigationBar.translucent = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.activityIndicator.alpha = 1.0
        self.activityIndicator.startAnimating()
        
        /* Set the UI, then check if the movie is a favorite/watchlist and update the buttons! */
        if let movie = movie {
            
            /* Set the title */
            if let releaseYear = movie.releaseYear {
                self.navigationItem.title = "\(movie.title) (\(releaseYear))"
            } else {
                self.navigationItem.title = "\(movie.title)"
            }
            
            /* Setting some default UI ... */
            posterImageView.image = UIImage(named: "MissingPoster")
            isFavorite = false
            isWatchlist = false
            
            /* Is the movie a favorite? */
            TMDBClient.sharedInstance().getFavoriteMovies { movies, error in
                if let movies = movies {
                    
                    for movie in movies {
                        if movie.id == self.movie!.id {
                            self.isFavorite = true
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        if self.isFavorite {
                            self.toggleFavoriteButton.tintColor = nil
                        } else {
                            self.toggleFavoriteButton.tintColor = UIColor.blackColor()
                        }
                    }
                } else {
                    print(error)
                }
            }
            
            /* Is the movie on watchlist? */
            TMDBClient.sharedInstance().getWatchlistMovies { movies, error in
                if let movies = movies {
                    
                    for movie in movies {
                        if movie.id == self.movie!.id {
                            self.isWatchlist = true
                        }
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        if self.isWatchlist {
                            self.toggleWatchlistButton.tintColor = nil
                        } else {
                            self.toggleWatchlistButton.tintColor = UIColor.blackColor()
                        }
                    }
                } else {
                    print(error)
                }
            }
            
            /* Set the poster image */
            if let posterPath = movie.posterPath {
                TMDBClient.sharedInstance().taskForGETImage(TMDBClient.PosterSizes.DetailPoster, filePath: posterPath, completionHandlerForImage: { (imageData, error) in
                    if let image = UIImage(data: imageData!) {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.activityIndicator.alpha = 0.0
                            self.activityIndicator.stopAnimating()
                            self.posterImageView.image = image
                        }
                    }
                })
            } else {
                self.activityIndicator.alpha = 0.0
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    // MARK: Actions
    
    @IBAction func toggleFavorite(sender: AnyObject) {
        TMDBClient.sharedInstance().postToFavorites(movie!, favorite: !self.isFavorite) { (status_code, error) -> Void in
            if let err = error {
                print(err)
            } else {
                if status_code == 1 || status_code == 12 || status_code == 13 {
                    self.isFavorite = !self.isFavorite
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.toggleFavoriteButton.tintColor = status_code == 13 ? UIColor.blackColor() : nil
                    })
                } else {
                    print("Unexpected status code \(status_code)")
                }
            }
        }
    }

    
    @IBAction func toggleWatchlist(sender: AnyObject) {
        TMDBClient.sharedInstance().postToWatchlist(movie!, watchlist: !self.isWatchlist) { (status_code, error) -> Void in
            if let err = error {
                print(err)
            } else {
                if status_code == 1 || status_code == 12 || status_code == 13 {
                    self.isWatchlist = !self.isWatchlist
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.toggleWatchlistButton.tintColor = status_code == 13 ? UIColor.blackColor() : nil
                    })
                } else {
                    print("Unexpected status code \(status_code)")
                }
            }
        }
    }
}
