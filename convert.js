// Not tested yet

const fs = require('fs');

// Function to convert MongoDB data to Firestore format
function convertToFirestore(mongoData) {
    const firestoreData = {};

    mongoData.forEach(doc => {
        const id = doc._id;
        delete doc._id;
        firestoreData[id] = doc;
    });

    return firestoreData;
}

// Read the MongoDB JSON data files
const files = fs.readdirSync('.').filter(file => file.startsWith('mongoData') && file.endsWith('.json'));

files.forEach((file, index) => {
    const mongoData = JSON.parse(fs.readFileSync(file, 'utf8'));
    const firestoreData = convertToFirestore(mongoData);
    const outputFilename = `firestoreData${index + 1}.json`;
    fs.writeFileSync(outputFilename, JSON.stringify(firestoreData, null, 2));
    console.log(`Conversion complete. Firestore data saved to ${outputFilename}`);
});