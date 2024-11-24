const express = require('express');
const multer = require('multer');
const path = require('path');

// Initialize Express app
const app = express();

// Set up multer storage and file handling
const storage = multer.diskStorage({
	destination: (req, file, cb) => {
		cb(null, 'uploads'); // Where you want to save the files
	},
	filename: (req, file, cb) => {
		cb(null, Date.now() + path.extname(file.originalname)); // Renaming file with timestamp
	},
});

const upload = multer({ storage: storage });

// Route for handling image upload
app.post('/user/upload', upload.single('image'), (req, res) => {
	const { title, isChecked } = req.body; // Text fields from the form
	const image = req.file; // The uploaded file

	if (!image) {
		return res.status(400).json({ message: 'Image upload failed' });
	}

	// Respond with the uploaded file details
	res.json({
		message: 'File uploaded successfully!',
		file: image,
		title: title,
		isChecked: isChecked
	});
});

// Start server
const PORT = 3000;
app.listen(PORT, () => {
	console.log(`Server is running on http://localhost:${PORT}`);
});
