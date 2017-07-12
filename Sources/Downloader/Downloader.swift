//
//  Downloader.swift
//  DownloadToGoSample
//
//  Created by Gal Orlanczyk on 06/07/2017.
//  Copyright © 2017 Kaltura. All rights reserved.
//

import Foundation

/// `DownloadItemTask` represents one file to download (could be video, audio or captions)
struct DownloadItemTask {
    /// The content url, should be unique!
    let contentUrl: URL
    let trackType: DTGTrackType
    /// The destination to save the download item to.
    let destinationUrl: URL
    
    var resumeData: Data? = nil
}

enum DownloaderState: String {
    /// Downloader was created but haven't start downloading.
    case new
    /// Downloader is currently downloading items.
    case downloading
    /// Downloader was paused.
    case paused
    /// Downloader finished all download tasks, can add more or stop the session.
    case idle
    /// Downloads were cancelled and the downloader session is unusable at this state.
    case cancelled
}

protocol Downloader: class {
    /// The session identifier, used to restore background sessions and to identify them.
    var sessionIdentifier: String { get }
    
    /// The downloader delegate object.
    weak var delegate: DownloaderDelegate? { get set }
    
    /// Background completion handler, can be received from application delegate when woken to background.
    /// Should be invoked when `urlSessionDidFinishEvents` is called.
    var backgroundSessionCompetionHandler: (() -> Void)? { get set }
    
    /// The max allowed concurrent download tasks.
    var maxConcurrentDownloadItemTasks: Int { get }
    
    /// The related dtg item id
    var dtgItemId: String { get }
    
    /// The state of the downloader.
    var state: DownloaderState { get }
    
    init(itemId: String, tasks: [DownloadItemTask])
    
    /// Starts the download according to the tasks ordering in the queue.
    /// use this only for the initial start.
    func start() throws
    
    /// Used to add more download tasks to the session.
    func addDownloadItemTasks(_ tasks: [DownloadItemTask]) throws
    
    /// Pauses all active downloads. and put the active downloads back in the queue.
    func pause()
    
    /// Cancels all active downloads and invalidates the session.
    func cancel()
    
    /// Invalidate the session. after invalidating the session is not usable anymore.
    func invalidateSession()
    
    /// creates a new background url session replacing current session.
    func refreshSession()
}

protocol DownloaderDelegate: class {
    func downloader(_ downloader: Downloader, didProgress bytesWritten: Int64)
    func downloader(_ downloader: Downloader, didPauseDownloadTasks tasks: [DownloadItemTask])
    func downloaderDidCancelDownloadTasks(_ downloader: Downloader)
    func downloader(_ downloader: Downloader, didFinishDownloading downloadItemTask: DownloadItemTask)
    func downloader(_ downloader: Downloader, didChangeToState newState: DownloaderState)
    func downloader(_ downloader: Downloader, didBecomeInvalidWithError error: Error?)
    /// Called when downloader failed due to fatal error
    func downloader(_ downloader: Downloader, didFailWithError error: Error)
}