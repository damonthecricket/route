//
//  ViewController.swift
//  Routes
//
//  Created by Damon Cricket on 27.08.2019.
//  Copyright © 2019 DC. All rights reserved.
//

import UIKit
import MapKit

// MARK: - MainViewController

class MainViewController: UIViewController, MKMapViewDelegate {
    
    enum State {
        case map
        case add
    }
    
    @IBOutlet private weak var mapView: MKMapView?
    @IBOutlet private weak var addButton: UIButton?
    @IBOutlet private weak var closeButton: UIButton?
    
    private var startAnnotation: MKPointAnnotation? = nil
    private var endAnnotation: MKPointAnnotation? = nil
    private var overlay: MKOverlay? = nil
    
    private var state: State = .map

    // MARK: - Object LifeCycle
    
    deinit {
        startAnnotation = nil
        endAnnotation = nil
        overlay = nil
    }
    
    // MARK: - Controller LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - UIActions
    
    @IBAction private func addButtonTap(sender: UIButton) {
        state = .add
        addButton?.isHidden = true
        closeButton?.isHidden = false
    }
    
    @IBAction private func closeButtonTap(sender: UIButton) {
        state = .map
        addButton?.isHidden = false
        closeButton?.isHidden = true
        
        deletePath()
    }
    
    @IBAction private func tapGestureRecognizer(sender: UITapGestureRecognizer) {
        switch state {
        case .map: break
        case .add:
            
            let location = sender.location(in: mapView)
            if let coordiante = mapView?.convert(location, toCoordinateFrom: mapView) {
                if startAnnotation == nil {
                    startAnnotation = MKPointAnnotation()
                    startAnnotation?.coordinate = coordiante
                    
                    mapView?.addAnnotation(startAnnotation!)
                } else if endAnnotation == nil {
                    let startPlacemark = MKPlacemark(coordinate: startAnnotation!.coordinate)
                    let endPlacemark = MKPlacemark(coordinate: coordiante)
                    
                    let startMapItem = MKMapItem(placemark: startPlacemark)
                    let endMapItem = MKMapItem(placemark: endPlacemark)
                    
                    endAnnotation = MKPointAnnotation()
                    endAnnotation?.coordinate = coordiante
                    
                    mapView?.addAnnotation(endAnnotation!)
                    
                    let directionRequest = MKDirectionsRequest()
                    directionRequest.source = startMapItem
                    directionRequest.destination = endMapItem
                    directionRequest.transportType = .walking
                    
                    let directions = MKDirections(request: directionRequest)
                    directions.calculate { (responce, error) in
                        
                        guard let responce = responce else {
                            if let error = error {
                                print("Dirrection calculate error \(error)")
                            }
                            return
                        }

                        self.overlay = responce.routes[0].polyline
                        self.mapView?.add((self.overlay!), level: .aboveRoads)
                    }
                } else {
                    deletePath()
                }
            }
        }
    }
    
    private func deletePath() {
        if let overlay = overlay {
            mapView?.removeOverlays([overlay])
            self.overlay = nil
        }
        
        mapView?.removeAnnotations(mapView!.annotations)
        
        startAnnotation = nil
        endAnnotation = nil
    }
    
    // MARK: - MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        return renderer
    }
}

