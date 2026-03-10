import axios from 'axios';
import * as dotenv from 'dotenv';

dotenv.config();

/**
 * Service to handle communication with WorkHub24 external API
 * for authentication and card data retrieval
 */

const WORKHUB24_AUTH_URL = process.env.WORKHUB24_AUTH_URL;
const WORKHUB24_CARD_URL = process.env.WORKHUB24_CARD_URL;

/**
 * Gets access token from WorkHub24 API
 * @returns {Promise<string>} - Access token
 */
export const getWorkHub24AccessToken = async () => {
  try {
    const clientId = process.env.WORKHUB24_CLIENT_ID;
    const clientSecret = process.env.WORKHUB24_CLIENT_SECRET;

    if (!clientId || !clientSecret) {
      throw new Error('WorkHub24 credentials not configured');
    }

    const response = await axios.post(
      WORKHUB24_AUTH_URL,
      {
        client_id: clientId,
        client_secret: clientSecret,
        grant_type: 'client_credentials',
      },
      {
        headers: {
          'Content-Type': 'application/json',
        },
        timeout: 120000, // 2 minutes timeout
      }
    );

    if (response.data && response.data.access_token) {
      return response.data.access_token;
    }

    throw new Error('Access token not found in response');
  } catch (error) {
    console.error('WorkHub24 access token error:', error.message);
    
    if (error.response) {
      console.error('WorkHub24 API response error:', {
        status: error.response.status,
        data: error.response.data,
      });
      
      if (error.response.status === 401 || error.response.status === 403) {
        throw new Error('Invalid WorkHub24 credentials');
      }
    }
    
    const errorMessage = error.code === 'ECONNREFUSED' 
      ? 'WorkHub24 authentication service is currently unavailable'
      : error.code === 'ETIMEDOUT'
      ? 'WorkHub24 authentication service timeout'
      : `Failed to get access token: ${error.message}`;
      
    throw new Error(errorMessage);
  }
};

/**
 * Gets card data from WorkHub24 API
 * @param {string} cardId - The card ID
 * @param {string} accessToken - The access token
 * @returns {Promise<Object>} - Card data with CSA and customer information
 */
export const getWorkHub24CardData = async (cardId, accessToken) => {
  try {
    if (!cardId) {
      throw new Error('Card ID is required');
    }

    if (!accessToken) {
      throw new Error('Access token is required');
    }

    const response = await axios.get(
      `${WORKHUB24_CARD_URL}/${cardId}`,
      {
        headers: {
          'Authorization': `Bearer ${accessToken}`,
          'Content-Type': 'application/json',
        },
        timeout: 120000, // 2 minutes timeout
      }
    );

    if (response.data) {
      return response.data;
    }

    throw new Error('Card data not found in response');
  } catch (error) {
    console.error('WorkHub24 card data error:', error.message);
    
    if (error.response) {
      console.error('WorkHub24 API response error:', {
        status: error.response.status,
        data: error.response.data,
      });
      
      if (error.response.status === 404) {
        throw new Error('Card not found');
      }
      
      if (error.response.status === 401 || error.response.status === 403) {
        throw new Error('Invalid or expired access token');
      }
    }
    
    const errorMessage = error.code === 'ECONNREFUSED' 
      ? 'WorkHub24 service is currently unavailable'
      : error.code === 'ETIMEDOUT'
      ? 'WorkHub24 service timeout'
      : `Failed to get card data: ${error.message}`;
      
    throw new Error(errorMessage);
  }
};

/**
 * Validates a card and returns CSA and customer data
 * @param {string} cardId - The card ID
 * @returns {Promise<Object>} - Object containing CSA and customer information
 */
export const validateCardAndGetData = async (cardId) => {
  try {
    // Get access token
    const accessToken = await getWorkHub24AccessToken();
    
    // Get card data
    const cardData = await getWorkHub24CardData(cardId, accessToken);
    
    // Extract CSA and customer information
    const csaName = cardData.walletTriggerUserName;
    const csaEmail = cardData.walletTriggerUserEmail;
    const customerName = cardData.name1;
    const customerEmail = cardData.email3;
    
    if (!csaName || !csaEmail) {
      throw new Error('CSA information (walletTriggerUserName, walletTriggerUserEmail) not found in card data');
    }
    
    if (!customerName || !customerEmail) {
      throw new Error('Customer information (name1, email3) not found in card data');
    }
    
    return {
      csa: {
        name: csaName,
        email: csaEmail,
      },
      customer: {
        name: customerName,
        email: customerEmail,
      },
    };
  } catch (error) {
    console.error('Card validation error:', error.message);
    throw error;
  }
};
