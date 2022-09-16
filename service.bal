import ballerina/io;
import ballerina/regex;
import ballerina/http;

public type Billionaire record {
    string name;
    decimal netWorth;
    string country;
    string industry;
};

service / on new http:Listener(8080) {

    private Billionaire[] billionaires = [];

    function init() returns error? {
        string[][] data = check io:fileReadCsv("TopRichestInWorld.csv", 1);

        foreach string[] line in data {
            string netWorthStr = regex:replaceAll(line[1], ",", "");
            netWorthStr = regex:replaceAll(netWorthStr, "\\$", "");

            Billionaire b = {
                name: line[0],
                netWorth: check decimal:fromString(netWorthStr),
                country: line[3],
                industry: line[5]
            };

            self.billionaires.push(b);
        }
        io:println("Loaded ", self.billionaires.length(), " billionaires");
    }

    resource function get billionaires(string country) returns Billionaire[] {
        return from var billionaire in self.billionaires
            where billionaire.country === country
            select billionaire;
    }
}
