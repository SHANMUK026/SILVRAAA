const axios = require('axios');

const GOLDAPI_KEY = process.env.GOLDAPI_KEY || 'goldapi-test-key'; // Placeholder
const BASE_URL = 'https://www.goldapi.io/api';

/**
 * Service to fetch real-time Gold and Silver prices.
 * In a production app, we would cache these in Redis for 1-5 minutes.
 */
class PriceService {
  static async getSpotPrice(symbol = 'XAU') {
    try {
      // symbol: XAU (Gold), XAG (Silver)
      // curr: INR (Indian Rupee)
      const response = await axios.get(`${BASE_URL}/${symbol}/INR`, {
        headers: {
          'x-access-token': GOLDAPI_KEY,
          'Content-Type': 'application/json'
        }
      });
      
      // price returned by GoldAPI is usually per ounce. 1 ounce = 31.1035 grams.
      // We convert to price per gram.
      const pricePerOunce = response.data.price;
      const pricePerGram = pricePerOunce / 31.1035;
      
      return pricePerGram;
    } catch (error) {
      console.warn(`Price API Error (${symbol}): Using fallback...`);
      return symbol === 'XAU' ? 6245.5 : 80.0; // Fallback hardcoded
    }
  }

  static async getLatestPrices() {
    const gold = await this.getSpotPrice('XAU');
    const silver = await this.getSpotPrice('XAG');
    
    // Add operational markups (e.g. 2% fintech margin)
    const markup = 1.02; 
    
    return {
      gold: gold * markup,
      silver: silver * markup,
      timestamp: new Date()
    };
  }
}

module.exports = PriceService;
