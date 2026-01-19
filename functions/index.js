const functions = require('firebase-functions');
const {onCall, HttpsError} = require('firebase-functions/v2/https');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();

/**
 * Creates an admin user without automatically signing them in
 * This function uses Firebase Admin SDK to create users without affecting the current session
 */
exports.createAdmin = functions.https.onCall(async (data, context) => {
  // Verify that the caller is authenticated and is an admin
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to create admin users'
    );
  }

  // Verify the caller is an admin
  const callerUserDoc = await admin.firestore()
    .collection('users')
    .doc(context.auth.uid)
    .get();

  if (!callerUserDoc.exists) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'User document not found'
    );
  }

  const callerRole = callerUserDoc.data().role;
  if (callerRole !== 'admin') {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Only admins can create admin users'
    );
  }

  // Extract data from request
  const { email, password, name, accessLevel } = data;

  if (!email || !password || !name || !accessLevel) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing required fields: email, password, name, accessLevel'
    );
  }

  try {
    // Split name into firstName and lastName
    const nameParts = name.trim().split(' ');
    const firstName = nameParts.length > 0 ? nameParts[0] : '';
    const lastName = nameParts.length > 1 ? nameParts.slice(1).join(' ') : '';

    // Create user in Firebase Authentication using Admin SDK
    // This does NOT sign in the user automatically
    const userRecord = await admin.auth().createUser({
      email: email,
      password: password,
      emailVerified: false,
    });

    const userId = userRecord.uid;

    // Create user document in Firestore with admin role
    await admin.firestore().collection('users').doc(userId).set({
      email: email,
      role: 'admin',
      profileId: null, // Will be updated after profile creation
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Create admin profile
    const profileRef = await admin.firestore()
      .collection('adminProfiles')
      .add({
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        accessLevel: accessLevel,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    const profileId = profileRef.id;

    // Update user with profileId
    await admin.firestore().collection('users').doc(userId).update({
      profileId: profileId,
    });

    // Return the created admin profile data
    return {
      profileId: profileId,
      userId: userId,
      name: name,
      accessLevel: accessLevel,
      email: email,
    };
  } catch (error) {
    console.error('Error creating admin user:', error);
    throw new functions.https.HttpsError(
      'internal',
      `Failed to create admin user: ${error.message}`
    );
  }
});

/**
 * Creates a candidate user without automatically signing them in
 * This function uses Firebase Admin SDK to create users without affecting the current session
 */
exports.createCandidate = onCall(async (request) => {
  const {data, auth} = request;
  
  // Verify that the caller is authenticated and is an admin
  if (!auth) {
    throw new HttpsError(
      'unauthenticated',
      'User must be authenticated to create candidate users'
    );
  }

  // Verify the caller is an admin
  const callerUserDoc = await admin.firestore()
    .collection('users')
    .doc(auth.uid)
    .get();

  if (!callerUserDoc.exists) {
    throw new HttpsError(
      'permission-denied',
      'User document not found'
    );
  }

  const callerRole = callerUserDoc.data().role;
  if (callerRole !== 'admin') {
    throw new HttpsError(
      'permission-denied',
      'Only admins can create candidate users'
    );
  }

  // Extract data from request
  const { email, password, firstName, lastName, phone, address } = data;

  if (!email || !password || !firstName || !lastName) {
    throw new HttpsError(
      'invalid-argument',
      'Missing required fields: email, password, firstName, lastName'
    );
  }

  try {
    // Create user in Firebase Authentication using Admin SDK
    // This does NOT sign in the user automatically
    const userRecord = await admin.auth().createUser({
      email: email,
      password: password,
      emailVerified: false,
    });

    const userId = userRecord.uid;

    // Create user document in Firestore with candidate role
    await admin.firestore().collection('users').doc(userId).set({
      email: email,
      role: 'candidate',
      profileId: null, // Will be updated after profile creation
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Create candidate profile
    const profileRef = await admin.firestore()
      .collection('candidateProfiles')
      .add({
        userId: userId,
        firstName: firstName.trim(),
        lastName: lastName.trim(),
        phone: phone?.trim() || '',
        address: address?.trim() || '',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    const profileId = profileRef.id;

    // Update user with profileId
    await admin.firestore().collection('users').doc(userId).update({
      profileId: profileId,
    });

    // Return the created candidate profile data
    return {
      profileId: profileId,
      userId: userId,
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: email,
    };
  } catch (error) {
    console.error('Error creating candidate user:', error);
    throw new HttpsError(
      'internal',
      `Failed to create candidate user: ${error.message}`
    );
  }
});

/**
 * Deletes a candidate user and all associated data
 * This function deletes:
 * - All candidate documents from Storage
 * - All candidate documents from Firestore
 * - All applications from Firestore
 * - Candidate profile from Firestore
 * - User document from Firestore
 * - User from Firebase Authentication
 */
exports.deleteCandidate = onCall(async (request) => {
  const {data, auth} = request;
  
  // Verify that the caller is authenticated and is an admin
  if (!auth) {
    throw new HttpsError(
      'unauthenticated',
      'User must be authenticated to delete candidates'
    );
  }

  // Verify the caller is an admin
  const callerUserDoc = await admin.firestore()
    .collection('users')
    .doc(auth.uid)
    .get();

  if (!callerUserDoc.exists) {
    throw new HttpsError(
      'permission-denied',
      'User document not found'
    );
  }

  const callerRole = callerUserDoc.data().role;
  if (callerRole !== 'admin') {
    throw new HttpsError(
      'permission-denied',
      'Only admins can delete candidates'
    );
  }

  // Extract data from request
  const { userId, profileId } = data;

  if (!userId || !profileId) {
    throw new HttpsError(
      'invalid-argument',
      'Missing required fields: userId, profileId'
    );
  }

  try {
    // Step 1: Get all candidate documents
    const documentsSnapshot = await admin.firestore()
      .collection('candidateDocuments')
      .where('candidateId', '==', userId)
      .get();

    // Step 2: Delete all document files from Storage
    const bucket = admin.storage().bucket();
    
    for (const doc of documentsSnapshot.docs) {
      const docData = doc.data();
      const storageUrl = docData.storageUrl;
      
      if (storageUrl) {
        try {
          // Extract file path from storage URL
          // Storage URLs format: https://firebasestorage.googleapis.com/v0/b/{bucket}/o/{pathEncoded}?alt=media&token={token}
          const urlObj = new URL(storageUrl);
          const pathMatch = urlObj.pathname.match(/\/o\/(.+?)(\?|$)/);
          if (pathMatch && pathMatch[1]) {
            // Decode the path (it's URL encoded, %2F represents /)
            let filePath = decodeURIComponent(pathMatch[1]);
            // Handle double encoding if needed
            if (filePath.includes('%')) {
              filePath = decodeURIComponent(filePath);
            }
            const file = bucket.file(filePath);
            await file.delete().catch(err => {
              console.warn(`Failed to delete storage file ${filePath}:`, err.message);
            });
          }
        } catch (storageError) {
          console.warn(`Failed to delete storage file for document ${doc.id}:`, storageError.message);
          // Continue with other deletions even if storage deletion fails
        }
      }
      
      // Step 3: Delete document from Firestore
      await doc.ref.delete();
    }

    // Step 4: Get all applications for this candidate
    const applicationsSnapshot = await admin.firestore()
      .collection('applications')
      .where('candidateId', '==', userId)
      .get();

    // Step 5: Delete all applications from Firestore
    for (const app of applicationsSnapshot.docs) {
      await app.ref.delete();
    }

    // Step 6: Delete candidate profile from Firestore
    await admin.firestore()
      .collection('candidateProfiles')
      .doc(profileId)
      .delete();

    // Step 7: Delete user document from Firestore
    await admin.firestore()
      .collection('users')
      .doc(userId)
      .delete();

    // Step 8: Delete user from Firebase Authentication using Admin SDK
    await admin.auth().deleteUser(userId);

    return { success: true };
  } catch (error) {
    console.error('Error deleting candidate:', error);
    throw new HttpsError(
      'internal',
      `Failed to delete candidate: ${error.message}`
    );
  }
});

/**
 * Deletes a user from both Firebase Authentication and Firestore
 * This function uses Firebase Admin SDK to delete any user
 */
exports.deleteUser = functions.https.onCall(async (data, context) => {
  // Verify that the caller is authenticated and is an admin
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to delete users'
    );
  }

  // Verify the caller is an admin
  const callerUserDoc = await admin.firestore()
    .collection('users')
    .doc(context.auth.uid)
    .get();

  if (!callerUserDoc.exists) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'User document not found'
    );
  }

  const callerRole = callerUserDoc.data().role;
  if (callerRole !== 'admin') {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Only admins can delete users'
    );
  }

  // Prevent deleting own account
  if (context.auth.uid === data.userId) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'You cannot delete your own account'
    );
  }

  // Extract data from request
  const { userId, profileId } = data;

  if (!userId || !profileId) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing required fields: userId, profileId'
    );
  }

  try {
    // Delete admin profile from Firestore
    await admin.firestore()
      .collection('adminProfiles')
      .doc(profileId)
      .delete();

    // Delete user document from Firestore
    await admin.firestore()
      .collection('users')
      .doc(userId)
      .delete();

    // Delete user from Firebase Authentication using Admin SDK
    await admin.auth().deleteUser(userId);

    return { success: true };
  } catch (error) {
    console.error('Error deleting user:', error);
    throw new functions.https.HttpsError(
      'internal',
      `Failed to delete user: ${error.message}`
    );
  }
});

/**
 * Sends a document denial email to a candidate
 * This function uses nodemailer with SMTP configuration from environment variables
 * 
 * Environment variables required (set via Firebase Console or gcloud):
 * - SMTP_HOST: SMTP server host (e.g., mail.wmsols.com)
 * - SMTP_PORT: SMTP server port (e.g., 465)
 * - SMTP_USER: SMTP username/email
 * - SMTP_PASSWORD: SMTP password
 * - EMAIL_FROM: From email address (e.g., test@wmsols.com)
 * - EMAIL_FROMNAME: From display name (e.g., ATS-Maximum)
 */
exports.sendDocumentDenialEmail = onCall(
  {
    // Set environment variables here or via Firebase Console
    // For now, we'll read from process.env which can be set via Console
  },
  async (request) => {
  const {data, auth} = request;
  
  // Verify that the caller is authenticated and is an admin
  if (!auth) {
    throw new HttpsError(
      'unauthenticated',
      'User must be authenticated to send emails'
    );
  }

  // Verify the caller is an admin
  const callerUserDoc = await admin.firestore()
    .collection('users')
    .doc(auth.uid)
    .get();

  if (!callerUserDoc.exists) {
    throw new HttpsError(
      'permission-denied',
      'User document not found'
    );
  }

  const callerRole = callerUserDoc.data().role;
  if (callerRole !== 'admin') {
    throw new HttpsError(
      'permission-denied',
      'Only admins can send emails'
    );
  }

  // Extract data from request
  const { candidateEmail, candidateName, documentName, denialReason } = data;

  if (!candidateEmail || !candidateName || !documentName) {
    throw new HttpsError(
      'invalid-argument',
      'Missing required fields: candidateEmail, candidateName, documentName'
    );
  }

  try {
    // Get SMTP configuration from environment variables
    // These must be set via Google Cloud Console or deployment configuration
    const host = process.env.SMTP_HOST;
    const port = process.env.SMTP_PORT || '587';
    const user = process.env.SMTP_USER;
    const password = process.env.SMTP_PASSWORD;
    const fromEmail = process.env.EMAIL_FROM;
    const fromName = process.env.EMAIL_FROMNAME;

    if (!host || !user || !password) {
      throw new Error('SMTP configuration is missing. Please set environment variables: SMTP_HOST, SMTP_USER, SMTP_PASSWORD');
    }

    if (!fromEmail || !fromName) {
      throw new Error('Email configuration is missing. Please set environment variables: EMAIL_FROM, EMAIL_FROMNAME');
    }

    // Create nodemailer transporter
    const transporter = nodemailer.createTransport({
      host: host,
      port: parseInt(port, 10),
      secure: port === '465', // true for 465, false for other ports
      auth: {
        user: user,
        pass: password,
      },
    });

    // Build email subject
    const subject = `Document Denial Notification - ${documentName}`;

    // Build email body (plain text)
    let emailBody = `Dear ${candidateName},\n\n`;
    emailBody += `We regret to inform you that your document "${documentName}" has been denied.\n\n`;
    
    if (denialReason && denialReason.trim().length > 0) {
      emailBody += `Reason for denial:\n${denialReason}\n\n`;
    }
    
    emailBody += `Please review the document requirements and re-upload the document with the necessary corrections.\n\n`;
    emailBody += `If you have any questions or need further clarification, please don't hesitate to contact us.\n\n`;
    emailBody += `Best regards,\n${fromName}`;

    // Send email
    const mailOptions = {
      from: `"${fromName}" <${fromEmail}>`,
      to: candidateEmail,
      subject: subject,
      text: emailBody,
    };

    const info = await transporter.sendMail(mailOptions);
    
    console.log('Email sent successfully:', info.messageId);
    
    return {
      success: true,
      messageId: info.messageId,
    };
  } catch (error) {
    console.error('Error sending email:', error);
    throw new HttpsError(
      'internal',
      `Failed to send email: ${error.message}`
    );
  }
});

/**
 * Sends a document request email to a candidate
 * This function uses nodemailer with SMTP configuration from environment variables
 * 
 * Environment variables required (set via Firebase Console or gcloud):
 * - SMTP_HOST: SMTP server host (e.g., mail.wmsols.com)
 * - SMTP_PORT: SMTP server port (e.g., 465)
 * - SMTP_USER: SMTP username/email
 * - SMTP_PASSWORD: SMTP password
 * - EMAIL_FROM: From email address (e.g., test@wmsols.com)
 * - EMAIL_FROMNAME: From display name (e.g., ATS-Maximum)
 */
exports.sendDocumentRequestEmail = onCall(
  {
    // Set environment variables here or via Firebase Console
    // For now, we'll read from process.env which can be set via Console
  },
  async (request) => {
  const {data, auth} = request;
  
  // Verify that the caller is authenticated and is an admin
  if (!auth) {
    throw new HttpsError(
      'unauthenticated',
      'User must be authenticated to send emails'
    );
  }

  // Verify the caller is an admin
  const callerUserDoc = await admin.firestore()
    .collection('users')
    .doc(auth.uid)
    .get();

  if (!callerUserDoc.exists) {
    throw new HttpsError(
      'permission-denied',
      'User document not found'
    );
  }

  const callerRole = callerUserDoc.data().role;
  if (callerRole !== 'admin') {
    throw new HttpsError(
      'permission-denied',
      'Only admins can send emails'
    );
  }

  // Extract data from request
  const { candidateEmail, candidateName, documentName, documentDescription } = data;

  if (!candidateEmail || !candidateName || !documentName || !documentDescription) {
    throw new HttpsError(
      'invalid-argument',
      'Missing required fields: candidateEmail, candidateName, documentName, documentDescription'
    );
  }

  try {
    // Get SMTP configuration from environment variables
    const host = process.env.SMTP_HOST;
    const port = process.env.SMTP_PORT || '587';
    const user = process.env.SMTP_USER;
    const password = process.env.SMTP_PASSWORD;
    const fromEmail = process.env.EMAIL_FROM;
    const fromName = process.env.EMAIL_FROMNAME;

    if (!host || !user || !password) {
      throw new Error('SMTP configuration is missing. Please set environment variables: SMTP_HOST, SMTP_USER, SMTP_PASSWORD');
    }

    if (!fromEmail || !fromName) {
      throw new Error('Email configuration is missing. Please set environment variables: EMAIL_FROM, EMAIL_FROMNAME');
    }

    // Create nodemailer transporter
    const transporter = nodemailer.createTransport({
      host: host,
      port: parseInt(port, 10),
      secure: port === '465', // true for 465, false for other ports
      auth: {
        user: user,
        pass: password,
      },
    });

    // Build email subject
    const subject = `Document Request - ${documentName}`;

    // Build email body (plain text)
    let emailBody = `Dear ${candidateName},\n\n`;
    emailBody += `We are requesting that you provide the following document:\n\n`;
    emailBody += `Document Name: ${documentName}\n`;
    emailBody += `Description: ${documentDescription}\n\n`;
    emailBody += `Please log in to your account and upload this document through the "My Documents" section.\n\n`;
    emailBody += `This document is specifically required from you. You will see it marked as "Requested" in your documents list.\n\n`;
    emailBody += `If you have any questions or need further clarification, please don't hesitate to contact us.\n\n`;
    emailBody += `Best regards,\n${fromName}`;

    // Send email
    const mailOptions = {
      from: `"${fromName}" <${fromEmail}>`,
      to: candidateEmail,
      subject: subject,
      text: emailBody,
    };

    const info = await transporter.sendMail(mailOptions);
    
    console.log('Email sent successfully:', info.messageId);
    
    return {
      success: true,
      messageId: info.messageId,
    };
  } catch (error) {
    console.error('Error sending email:', error);
    throw new HttpsError(
      'internal',
      `Failed to send email: ${error.message}`
    );
  }
});

/**
 * Sends a document request revocation email to a candidate
 * This function uses nodemailer with SMTP configuration from environment variables
 */
exports.sendDocumentRequestRevocationEmail = onCall(
  {
    // Set environment variables here or via Firebase Console
  },
  async (request) => {
  const {data, auth} = request;
  
  // Verify that the caller is authenticated and is an admin
  if (!auth) {
    throw new HttpsError(
      'unauthenticated',
      'User must be authenticated to send emails'
    );
  }

  // Verify the caller is an admin
  const callerUserDoc = await admin.firestore()
    .collection('users')
    .doc(auth.uid)
    .get();

  if (!callerUserDoc.exists) {
    throw new HttpsError(
      'permission-denied',
      'User document not found'
    );
  }

  const callerRole = callerUserDoc.data().role;
  if (callerRole !== 'admin') {
    throw new HttpsError(
      'permission-denied',
      'Only admins can send emails'
    );
  }

  // Extract data from request
  const { candidateEmail, candidateName, documentName } = data;

  if (!candidateEmail || !candidateName || !documentName) {
    throw new HttpsError(
      'invalid-argument',
      'Missing required fields: candidateEmail, candidateName, documentName'
    );
  }

  try {
    // Get SMTP configuration from environment variables
    const host = process.env.SMTP_HOST;
    const port = process.env.SMTP_PORT || '587';
    const user = process.env.SMTP_USER;
    const password = process.env.SMTP_PASSWORD;
    const fromEmail = process.env.EMAIL_FROM;
    const fromName = process.env.EMAIL_FROMNAME;

    if (!host || !user || !password) {
      throw new Error('SMTP configuration is missing. Please set environment variables: SMTP_HOST, SMTP_USER, SMTP_PASSWORD');
    }

    if (!fromEmail || !fromName) {
      throw new Error('Email configuration is missing. Please set environment variables: EMAIL_FROM, EMAIL_FROMNAME');
    }

    // Create nodemailer transporter
    const transporter = nodemailer.createTransport({
      host: host,
      port: parseInt(port, 10),
      secure: port === '465',
      auth: {
        user: user,
        pass: password,
      },
    });

    // Build email subject
    const subject = `Document Request Revoked - ${documentName}`;

    // Build email body (plain text)
    let emailBody = `Dear ${candidateName},\n\n`;
    emailBody += `We are informing you that the document request for "${documentName}" has been revoked.\n\n`;
    emailBody += `You are no longer required to provide this document. If you have already uploaded it, you may choose to keep or remove it from your documents.\n\n`;
    emailBody += `If you have any questions, please don't hesitate to contact us.\n\n`;
    emailBody += `Best regards,\n${fromName}`;

    // Send email
    const mailOptions = {
      from: `"${fromName}" <${fromEmail}>`,
      to: candidateEmail,
      subject: subject,
      text: emailBody,
    };

    const info = await transporter.sendMail(mailOptions);
    
    console.log('Email sent successfully:', info.messageId);
    
    return {
      success: true,
      messageId: info.messageId,
    };
  } catch (error) {
    console.error('Error sending email:', error);
    throw new HttpsError(
      'internal',
      `Failed to send email: ${error.message}`
    );
  }
});

/**
 * Sends an email notification to a candidate when admin uploads a document on their behalf
 * This function uses nodemailer with SMTP configuration from environment variables
 * 
 * Environment variables required (set via Firebase Console or gcloud):
 * - SMTP_HOST: SMTP server host (e.g., mail.wmsols.com)
 * - SMTP_PORT: SMTP server port (e.g., 465)
 * - SMTP_USER: SMTP username/email
 * - SMTP_PASSWORD: SMTP password
 * - EMAIL_FROM: From email address (e.g., test@wmsols.com)
 * - EMAIL_FROMNAME: From display name (e.g., ATS-Maximum)
 */
exports.sendAdminDocumentUploadEmail = onCall(
  {
    // Set environment variables here or via Firebase Console
  },
  async (request) => {
  const {data, auth} = request;
  
  // Verify that the caller is authenticated and is an admin
  if (!auth) {
    throw new HttpsError(
      'unauthenticated',
      'User must be authenticated to send emails'
    );
  }

  // Verify the caller is an admin
  const callerUserDoc = await admin.firestore()
    .collection('users')
    .doc(auth.uid)
    .get();

  if (!callerUserDoc.exists) {
    throw new HttpsError(
      'permission-denied',
      'User document not found'
    );
  }

  const callerRole = callerUserDoc.data().role;
  if (callerRole !== 'admin') {
    throw new HttpsError(
      'permission-denied',
      'Only admins can send emails'
    );
  }

  // Extract data from request
  const { candidateEmail, candidateName, documentName } = data;

  if (!candidateEmail || !candidateName || !documentName) {
    throw new HttpsError(
      'invalid-argument',
      'Missing required fields: candidateEmail, candidateName, documentName'
    );
  }

  try {
    // Get SMTP configuration from environment variables
    const host = process.env.SMTP_HOST;
    const port = process.env.SMTP_PORT || '587';
    const user = process.env.SMTP_USER;
    const password = process.env.SMTP_PASSWORD;
    const fromEmail = process.env.EMAIL_FROM;
    const fromName = process.env.EMAIL_FROMNAME;

    if (!host || !user || !password) {
      throw new Error('SMTP configuration is missing. Please set environment variables: SMTP_HOST, SMTP_USER, SMTP_PASSWORD');
    }

    if (!fromEmail || !fromName) {
      throw new Error('Email configuration is missing. Please set environment variables: EMAIL_FROM, EMAIL_FROMNAME');
    }

    // Create nodemailer transporter
    const transporter = nodemailer.createTransport({
      host: host,
      port: parseInt(port, 10),
      secure: port === '465', // true for 465, false for other ports
      auth: {
        user: user,
        pass: password,
      },
    });

    // Build email subject
    const subject = `Document Uploaded on Your Behalf - ${documentName}`;

    // Build email body (plain text)
    let emailBody = `Dear ${candidateName},\n\n`;
    emailBody += `We are informing you that a document has been uploaded on your behalf:\n\n`;
    emailBody += `Document Name: ${documentName}\n\n`;
    emailBody += `This document has been uploaded by an administrator and is already approved. You can view it in your "My Documents" section.\n\n`;
    emailBody += `If you have any questions or concerns, please don't hesitate to contact us.\n\n`;
    emailBody += `Best regards,\n${fromName}`;

    // Send email
    const mailOptions = {
      from: `"${fromName}" <${fromEmail}>`,
      to: candidateEmail,
      subject: subject,
      text: emailBody,
    };

    const info = await transporter.sendMail(mailOptions);
    
    console.log('Email sent successfully:', info.messageId);
    
    return {
      success: true,
      messageId: info.messageId,
    };
  } catch (error) {
    console.error('Error sending email:', error);
    throw new HttpsError(
      'internal',
      `Failed to send email: ${error.message}`
    );
  }
});
