struct DomainModel {
    var text = "Hello, World!"
        // Leave this here; this value is also tested in the tests,
        // and serves to make sure that everything is working correctly
        // in the testing harness and framework.
}

////////////////////////////////////
// Money
//
public struct Money {
    var amount: Int
    var currency: String
    static var validCurrency = ["USD", "GBP", "EUR", "CAN"]
    static let toUSD: [String: Double] = [
        "USD": 1.0,
        "GBP": 2.0,
        "EUR": 2.0 / 3.0,
        "CAN": 0.8
    ]
    
    static let fromUSD: [String: Double] = [
        "USD": 1.0,
        "GBP": 0.5,
        "EUR": 1.5,
        "CAN": 1.25
    ]
    
    public init(amount: Int, currency: String){
        guard Money.validCurrency.contains(currency) else {
            fatalError("Invalid Currency")
        }
        self.amount = amount
        self.currency = currency
    }
    func convert(_ currency: String) -> Money {
        guard Money.validCurrency.contains(currency) else {
            fatalError("Invalid currency")
        }

        guard let rateToUSD = Money.toUSD[self.currency],
              let rateFromUSD = Money.fromUSD[currency] else {
            fatalError("Missing Conversion Rate")
        }

        let usd = Double(self.amount) * rateToUSD
        let converted = usd * rateFromUSD
        return Money(amount: Int(converted.rounded()), currency: currency)
    }

    func add(_ money: Money) -> Money {
        let convertedSelf = self.convert(money.currency)
        let total = convertedSelf.amount + money.amount
        return Money(amount: total, currency: money.currency)
    }

    func subtract(_ money: Money) -> Money{
        let converted = money.convert(self.currency)
        let total = self.amount - converted.amount
        return Money(amount: total, currency: self.currency)
    }
}


////////////////////////////////////
// Job
//
public class Job {
    public enum JobType {
        case Hourly(Double)
        case Salary(UInt)
    }
    
    let title: String
    var type: JobType
    
    public init(title: String, type: JobType){
        self.title = title
        self.type = type
    }
    
    func calculateIncome(_ hours: Int) -> Int {
        switch type {
        case .Hourly(let cost):
            return Int(cost * Double(hours))
        case .Salary(let salary):
            return Int(salary)
        }
    }

    func raise(byAmount: Double) {
        switch type {
        case .Hourly(let cost):
            type = .Hourly(cost + byAmount)
        case .Salary(let salary):
            type = .Salary(salary + UInt(byAmount))
        }
    }

    func raise(byPercent: Double) {
        let raise = 1.0 + byPercent
        switch type {
        case .Hourly(let cost):
            let wage = cost * raise
            type = .Hourly(wage)
        case .Salary(let salary):
            let newSal = Double(salary) * raise
            type = .Salary(UInt(newSal))
        }
    }

}

////////////////////////////////////
// Person
//
public class Person {
    var firstName: String
    var lastName: String
    var age: Int
    private var _spouse: Person?
    private var _job: Job?
    var job: Job? {
        get {
            return _job
        } set {
            if age <= 16{
                _job = nil
            } else {
                _job = newValue
            }
        }
    }
    
    var spouse: Person? {
        get {
            return _spouse
        } set {
            if age <= 18 {
                _spouse = nil
                
            } else {
                _spouse = newValue
            }
        }
    }
    
    public init(firstName: String, lastName: String, age: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
        self._job = nil
        self._spouse = nil
    }
    
    func toString() -> String {
        let jobString = job.map { "\($0)" } ?? "nil"
        let spouseString = spouse.map { "\($0.firstName)\(" ")\($0.lastName)" } ?? "nil"
        return "[Person: firstName:\(firstName) lastName:\(lastName) age:\(age) job:\(jobString) spouse:\(spouseString)]"
    }

}

////////////////////////////////////
// Family
//
public class Family {
    var fam: [Person]
    public init(spouse1: Person, spouse2: Person) {
        guard spouse1.spouse == nil && spouse2.spouse == nil else{
            fatalError("You can only be apart of one Family")
        }
        
        spouse1.spouse = spouse2
        spouse2.spouse = spouse1
        self.fam = [spouse1, spouse2]
    }
    
    func haveChild(_ child: Person) -> Bool{
        guard fam.contains(where: {$0.age >= 21 }) else {
            return false
        }
        fam.append(child)
        return true
    }
    
    func householdIncome(_ hoursWorked: Int? = nil) -> Int {
        let hours = hoursWorked ?? 2000
        return fam
            .compactMap { $0.job?.calculateIncome(hours) }
            .reduce(0, +)
    }

}
