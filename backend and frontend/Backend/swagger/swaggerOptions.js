export const options = {
    definition: {
      openapi: "3.1.0",
      info: {
        title: "ACORN Travels API Documentation",
        version: "2.0.0",
        description: "Comprehensive API documentation for ACORN Travels Mobile App and Admin Portal. This API provides endpoints for customer management, travel bookings, incident reporting, feedback collection, and authentication.",
        contact: {
          name: "ACORN Travels Development Team",
          email: "dev@acorntravels.com",
        },
        license: {
          name: "MIT",
          url: "https://opensource.org/licenses/MIT",
        },
      },
      servers: [
        {
          url: "http://localhost:8000/api/v1",
          description: "Development server"
        },
        {
          url: "https://api.acorntravels.com/api/v1",
          description: "Production server"
        }
      ],
      components: {
        securitySchemes: {
          bearerAuth: {
            type: "http",
            scheme: "bearer",
            bearerFormat: "JWT",
            description: "JWT token for authentication"
          },
          ApiKeyAuth: {
            type: "apiKey",
            in: "header",
            name: "X-API-Key",
            description: "API key for external application authentication"
          }
        },
        schemas: {
          Error: {
            type: "object",
            properties: {
              success: {
                type: "boolean",
                example: false
              },
              error: {
                type: "object",
                properties: {
                  message: {
                    type: "string",
                    example: "Error message"
                  }
                }
              }
            }
          },
          Success: {
            type: "object",
            properties: {
              success: {
                type: "boolean",
                example: true
              },
              message: {
                type: "string",
                example: "Operation successful"
              }
            }
          }
        }
      },
      security: [
        {
          bearerAuth: []
        }
      ]
    },
    apis: ["./routes/*.js"],
  };