/// Global constant for Github OAuth Login base url
const String kApiBaseEndpoint = 'https://github.com/login/oauth';

/// Global constant for Github OAuth Login access token endpoint
const String kApiEndpointAccessToken = '$kApiBaseEndpoint/access_token';

/// Global constant for Github OAuth Login authorize endpoint
const String kApiEndpointAuthorize = '$kApiBaseEndpoint/authorize';

/// Global key constant for Github OAuth Login that to be
/// passed to the API call to get the access token
/// while logging in with [GithubAuth.clientId] and [GithubAuth.clientSecret].
const String kCodeConstant = 'code';

/// Global key constant for to get the access token from the json response.
const String kAccessTokenConstant = 'access_token';

/// Global Key constant to put the client secret in the request body.
const String kClientSecretConstant = 'client_secret';

/// Global Key constant to put the client id in the request body.
const String kClientIdConstant = "client_id";

/// Global Key constant to put the headers in the request body.
const String kAcceptConstant = "Accept";

/// Global Value constant to put the headers in the request body.
const String kAcceptJsonConstant = "application/json";

/// Global Key constant to get the error from the json response.
const String kErrorConstant = "error";
