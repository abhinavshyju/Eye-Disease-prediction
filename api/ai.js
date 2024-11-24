const fs = require("fs");
const API_KEY = process.env.API_KEY;

const { GoogleGenerativeAI } = require("@google/generative-ai");

const genAI = new GoogleGenerativeAI(API_KEY);

const model = genAI.getGenerativeModel({ model: "gemini-1.5-flash" });

const DescriptionGen = async (image_path) => {
  const prompt =
    "Summarize this prescription want to make the result as markdown";
  // const prompt = 'Whats in the image';
  const image = {
    inlineData: {
      data: Buffer.from(fs.readFileSync(image_path)).toString("base64"),
      mimeType: "image/png",
    },
  };

  const result = await model.generateContent([prompt, image]);
  console.log(result.response.text());
  return result.response.text();
};
module.exports = DescriptionGen;
