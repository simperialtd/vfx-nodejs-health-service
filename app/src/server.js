const express = require("express");

const app = express();
const PORT = process.env.PORT || 8080;
const APP_VERSION = process.env.APP_VERSION || "unknown";
const APP_ENVIRONMENT = process.env.APP_ENVIRONMENT || "unknown";

app.get("/health", (_req, res) => {
  res.json({ status: "healthy", 
             environment: APP_ENVIRONMENT, 
             version: APP_VERSION 
          });
});

app.listen(PORT, () => {
  console.log(`Server running on port ${PORT}`);
});
