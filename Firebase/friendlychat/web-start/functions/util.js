const spawn = require("child-process-promise").spawn;
const path = require("path");
const os = require("os");
const fs = require("fs");
const admin = require("firebase-admin");

// Blurs the given image located in the given bucket using ImageMagick.
async function blurImage(filePath) {
    const tempLocalFile = path.join(os.tmpdir(), path.basename(filePath));
    const messageId = filePath.split(path.sep)[1];
    const bucket = admin.storage().bucket();

    // Download file from bucket.
    await bucket.file(filePath).download({
        destination: tempLocalFile
    });
    console.log('Image has been downloaded to', tempLocalFile);
    // Blur the image using ImageMagick.
    await spawn('convert', [tempLocalFile, '-channel', 'RGBA', '-blur', '0x24', tempLocalFile]);
    console.log('Image has been blurred');
    // Uploading the Blurred image back into the bucket.
    await bucket.upload(tempLocalFile, {
        destination: filePath
    });
    console.log('Blurred image has been uploaded to', filePath);
    // Deleting the local file to free up disk space.
    fs.unlinkSync(tempLocalFile);
    console.log('Deleted local file.');
    // Indicate that the message has been moderated.
    await admin.firestore().collection('messages').doc(messageId).update({
        moderated: true
    });
    console.log('Marked the image as moderated in the database.');
}

// Cleans up the tokens that are no longer valid.
function cleanupTokens(response, tokens) {
    // For each notification we check if there was an error.
    const tokensDelete = [];
    response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
            console.error('Failure sending notification to', tokens[index], error);
            // Cleanup the tokens who are not registered anymore.
            if (error.code === 'messaging/invalid-registration-token' ||
                error.code === 'messaging/registration-token-not-registered') {
                const deleteTask = admin.firestore().collection('messages').doc(tokens[index]).delete();
                tokensDelete.push(deleteTask);
            }
        }
    });
    return Promise.all(tokensDelete);
}

module.exports = {
    blurImage,
    cleanupTokens
};