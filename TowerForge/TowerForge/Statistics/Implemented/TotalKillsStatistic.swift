//
//  KillStatistic.swift
//  TowerForge
//
//  Created by Rubesh on 11/4/24.
//

import Foundation

final class TotalKillsStatistic: Statistic {

    var statisticName: StatisticName = .totalKills
    var permanentValue: Double = .zero
    var currentValue: Double = .zero

    var statisticUpdateLinks: StatisticUpdateLinkDatabase {
        self.getStatisticUpdateLinks()
    }

    init(name: StatisticName = .totalKills,
         permanentValue: Double = .zero,
         currentValue: Double = .zero) {
        self.statisticName = name
        self.permanentValue = permanentValue
        self.currentValue = currentValue
    }

    func getStatisticUpdateLinks() -> StatisticUpdateLinkDatabase {
        let eventType = TFEventTypeWrapper(type: KillEvent.self)
        let updateActor: StatisticUpdateActor = { statistic in statistic.updateCurrentValue(by: 1.0) }
        let eventUpdateDictionary = [eventType: updateActor]
        let statsLink = StatisticUpdateLinkDatabase(statisticUpdateLinks: eventUpdateDictionary)

        return statsLink
    }

}
