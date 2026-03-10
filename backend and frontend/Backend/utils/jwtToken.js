import jwt from "jsonwebtoken";
import * as dotenv from "dotenv";

dotenv.config();

export const generateAccessToken = (id, type) => {
  return jwt.sign(
    { userId: id, type }, 
    process.env.ACCESS_TOKEN_SECRET, 
    {
      expiresIn: "15m",
      issuer: "acorn-travels",
      audience: "acorn-travels-app"
    }
  );
};

export const generateRefreshToken = (id, type) => {
  return jwt.sign(
    { userId: id, type }, 
    process.env.REFRESH_TOKEN_SECRET, 
    {
      expiresIn: "3h",
      issuer: "acorn-travels",
      audience: "acorn-travels-app"
    }
  );
};

export const verifyRefreshToken = (token) => {
  return new Promise((resolve, reject) => {
    jwt.verify(
      token, 
      process.env.REFRESH_TOKEN_SECRET, 
      {
        issuer: "acorn-travels",
        audience: "acorn-travels-app"
      },
      (err, decoded) => {
        if (err) {
          reject(err);
        } else {
          resolve(decoded);
        }
      }
    );
  });
};

export const verifyAccessToken = (token) => {
  return new Promise((resolve, reject) => {
    jwt.verify(
      token, 
      process.env.ACCESS_TOKEN_SECRET, 
      {
        issuer: "acorn-travels",
        audience: "acorn-travels-app"
      },
      (err, decoded) => {
        if (err) {
          reject(err);
        } else {
          resolve(decoded);
        }
      }
    );
  });
};
