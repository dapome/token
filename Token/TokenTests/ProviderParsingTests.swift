import XCTest
@testable import Token

final class ProviderParsingTests: XCTestCase {
    func testOpenAIParsesCostAndUsageVariants() throws {
        let service = OpenAIUsageService()
        let payload = try jsonObject("""
        {
          "data": [
            {
              "results": [
                { "amount": { "value": "1.25" } },
                { "amount": "0.75" }
              ]
            }
          ]
        }
        """)

        let costs = try service.parseCostBuckets(from: payload)
        XCTAssertEqual(costs.reduce(Decimal.zero) { $0 + $1.totalCost }, Decimal(string: "2.00"))

        let usagePayload = try jsonObject("""
        {
          "data": [
            {
              "results": [
                {
                  "input_tokens": 100,
                  "output_tokens": "25",
                  "num_model_requests": 3
                }
              ]
            },
            {
              "result": [
                {
                  "input_tokens": 10,
                  "output_tokens": 5,
                  "num_model_requests": 1
                }
              ]
            }
          ]
        }
        """)

        let totals = service.aggregate(results: try service.parseUsageBuckets(from: usagePayload))
        XCTAssertEqual(totals.inputTokens, 110)
        XCTAssertEqual(totals.outputTokens, 30)
        XCTAssertEqual(totals.requestCount, 4)
    }

    func testAnthropicParsesCostAndCacheTokenVariants() throws {
        let decoder = JSONDecoder()
        let costResponse = try decoder.decode(AnthropicUsageService.CostResponse.self, from: Data("""
        {
          "data": [
            {
              "results": [
                { "amount": "1.20" },
                { "amount": { "value": "0.30" } }
              ]
            }
          ]
        }
        """.utf8))

        XCTAssertEqual(costResponse.data.first?.totalCost, Decimal(string: "1.50"))

        let usageResponse = try decoder.decode(AnthropicUsageService.UsageResponse.self, from: Data("""
        {
          "data": [
            {
              "results": [
                {
                  "input_tokens": 100,
                  "cache_creation": {
                    "ephemeral_5m_input_tokens": 10,
                    "ephemeral_1h_input_tokens": 20
                  },
                  "cache_read_input_tokens": 5,
                  "output_tokens": 15
                }
              ]
            }
          ]
        }
        """.utf8))

        let totals = AnthropicUsageService().aggregate(results: usageResponse.data)
        XCTAssertEqual(totals.inputTokens, 135)
        XCTAssertEqual(totals.outputTokens, 15)
    }

    func testOpenRouterParsesCreditsAndKeySpend() throws {
        let decoder = JSONDecoder()
        let credits = try decoder.decode(OpenRouterUsageService.CreditsResponse.self, from: Data("""
        {
          "data": {
            "total_credits": 50.5,
            "total_usage": 10.25
          }
        }
        """.utf8))

        XCTAssertEqual(credits.data.totalCredits, Decimal(string: "50.5"))
        XCTAssertEqual(credits.data.totalUsage, Decimal(string: "10.25"))

        let keys = try decoder.decode(OpenRouterUsageService.KeysResponse.self, from: Data("""
        {
          "data": [
            { "disabled": false, "usage_daily": 1.25, "usage_monthly": 7.5 },
            { "disabled": true, "usage_daily": 100, "usage_monthly": 100 }
          ]
        }
        """.utf8))

        let enabledKeys = keys.data.filter { !$0.disabled }
        XCTAssertEqual(enabledKeys.reduce(Decimal.zero) { $0 + $1.usageDaily }, Decimal(string: "1.25"))
        XCTAssertEqual(enabledKeys.reduce(Decimal.zero) { $0 + $1.usageMonthly }, Decimal(string: "7.5"))
    }

    private func jsonObject(_ json: String) throws -> [String: Any] {
        let object = try JSONSerialization.jsonObject(with: Data(json.utf8))
        return try XCTUnwrap(object as? [String: Any])
    }
}
