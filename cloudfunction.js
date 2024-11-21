const functions = require('firebase-functions');
const admin = require('firebase-admin');
// To avoid deployment errors, do not call admin.initializeApp() in your code

const algoliasearch = require('algoliasearch');
const cors = require('cors')({ origin: true });

// Initialize Algolia with your application ID and admin API key.
const algoliaClient = algoliasearch("APP_ID", "API_KEY");
exports.fetchFromAlgolia = functions.https.onRequest(async (req, res) => {
    cors(req, res, async () => {
        // Extract the token from the request headers
        const idToken = req.headers.authorization ? req.headers.authorization.split('Bearer ')[1] : null;

        if (!idToken) {
            return res.status(403).send('Unauthorized');
        }

        try {
            // Verify the token using Firebase Admin SDK
            const decodedToken = await admin.auth().verifyIdToken(idToken);
            console.log('User ID:', decodedToken.uid);

            // Parse request parameters
            const {
                latitude = 0,
                longitude = 0,
                radiusInMeters = -1,
                searchTerm = "",
                page = 0,
                hitsPerPage = 10,
                query = null,
                indexName = ''
            } = req.body;
            const algoliaIndex = algoliaClient.initIndex(indexName);

            // Initialize the search parameters object
            const searchParams = {
                page: page,
            };

            // Conditionally add parameters to the search options
            if (latitude !== null && longitude !== null) {
                if ((latitude + longitude) != 0)
                    searchParams.aroundLatLng = `${latitude},${longitude}`;
            }
            if (radiusInMeters !== null && radiusInMeters != -1) {
                searchParams.aroundRadius = radiusInMeters;
            }
            if (hitsPerPage !== null) {
                searchParams.hitsPerPage = hitsPerPage;
            }
            if (query !== null && query != '') {
                searchParams.filters = query == '' ? null : query;
            }

            // Perform the Algolia search with dynamic parameters
            const searchResults = await algoliaIndex.search(searchTerm, searchParams);

            // Process and return the results
            console.log(searchResults);
            res.json(searchResults.hits);
        } catch (error) {
            console.error('Error verifying token or Algolia search failed:', error);
            res.status(500).send('Error verifying token or Algolia search failed');
        }
    });
});
