//
//  ViewController.swift
//  JAPing
//
//  Created by JadianZheng on 09/03/2018.
//  Copyright (c) 2018 JadianZheng. All rights reserved.
//

import UIKit
import JAPing

extension Double {
    func roundUp(to decimal: Int) -> Double {
        let multiple: Double = pow(10.0, Double(decimal))
        return Darwin.round(self * multiple)/multiple
    }
}

class ViewController: UIViewController {
    let baiduPinger = JAPing(hostName: "10.1.16.70", unexpertError: nil)
    let hostSelector = JAHostSelector(hosts: ["baidu.com", "jd.com"]);
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pingBaidu()
//        mutiplePing()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(taped))
        view.addGestureRecognizer(tap)
    }
    
    @objc func taped() {
        pingBaidu()
    }
    
    func mutiplePing() {
        hostSelector.startPing(10) { [weak self] (fastestHost, sortedPingResults) in
            guard self != nil else { return }
            print("Fastest: \(fastestHost)")
            print(sortedPingResults)
//            self.mutiplePing()
        }
    }
    
    func pingBaidu() {
        baiduPinger.configuare.packageSize = 1000
        baiduPinger.resolvedHostHandle = { pinger, ip in
            print("PING \(pinger.hostName) (\(ip))")
        }
        
        baiduPinger.packetResponseHandle = { pinger, sequenceNumber, packet in
            print("\(packet.sendData.count) bytes from \(pinger.ip): icmp_seq=\(sequenceNumber) time=\(packet.roundTripTime.roundUp(to: 3)) ms")
        }
        
        baiduPinger.pingFinishHandle = { pinger, packets, statistic in
            if statistic.ip.isEmpty {
                print("JAPing: cannot resolve \(pinger.hostName): Unknown host")
                return
            }
            
            print("--- \(pinger.hostName) ping statistics ---")
            
            let lossPercent = (statistic.transmittedPacketCount - statistic.receivedPacketCount)/statistic.transmittedPacketCount * 100
            print("\(statistic.transmittedPacketCount) packets transmitted, \(statistic.receivedPacketCount) packets received, \(lossPercent)% packet loss")
            
            if statistic.receivedPacketCount > 0 {
                print("round-trip min/avg/max/stddev = \(statistic.minRoundTripTime.roundUp(to: 3))/\(statistic.avgRoundTripTime.roundUp(to: 3))/\(statistic.maxRoundTripTime.roundUp(to: 3))/\(statistic.stddevRoundTripTime.roundUp(to: 3)) ms")
//                pinger.start()
            }
        }
        
        baiduPinger.configuare.pingCount = 25
        baiduPinger.configuare.waitInterval = 0.2
        baiduPinger.start()
    }
}

