local Delete = import 'delete.jsonnet';
local Get = import 'get.jsonnet';
local Patch = import 'patch.jsonnet';
local Post = import 'post.jsonnet';
local Put = import 'put.jsonnet';

local ParamDay = import 'day.param.jsonnet';
local ParamMonth = import 'month.param.jsonnet';
local ParamPath = import 'path.param.jsonnet';
local ParamPeriod = import 'period.param.jsonnet';
local ParamYear = import 'year.param.jsonnet';


std.manifestYamlDoc(
  {
    openapi: '3.1.0',
    info: {
      title: 'LLM Bridges for Obsidian',
      description: "Interact with your Obsidian notes through this LLM Bridge API.\n\nPress the 'Authorize' button and supply your API key from plugin settings before sending requests. If your browser warns about the self-signed certificate, add it as a trusted certificate.",
      version: '1.0',
    },
    servers: [
      {
        url: 'https://{host}:{port}',
        description: 'HTTPS (Secure Mode)',
        variables: {
          port: {
            default: '27124',
            description: 'HTTPS port',
          },
          host: {
            default: '127.0.0.1',
            description: 'Binding host',
          },
        },
      },
      {
        url: 'http://{host}:{port}',
        description: 'HTTP (Insecure Mode)',
        variables: {
          port: {
            default: '27123',
            description: 'HTTP port',
          },
          host: {
            default: '127.0.0.1',
            description: 'Binding host',
          },
        },
      },
    ],
    components: {
      securitySchemes: {
        apiKeyAuth: {
          description: 'Find your API Key in your Obsidian settings\nin the "LLM Bridges" section under "Plugins".\n',
          type: 'http',
          scheme: 'bearer',
        },
      },
      schemas: {
        NoteJson: {
          type: 'object',
          required: [
            'tags',
            'frontmatter',
            'stat',
            'path',
            'content',
          ],
          properties: {
            tags: {
              type: 'array',
              items: {
                type: 'string',
              },
            },
            frontmatter: {
              type: 'object',
            },
            stat: {
              type: 'object',
              required: [
                'ctime',
                'mtime',
                'size',
              ],
              properties: {
                ctime: {
                  type: 'number',
                },
                mtime: {
                  type: 'number',
                },
                size: {
                  type: 'number',
                },
              },
            },
            path: {
              type: 'string',
            },
            content: {
              type: 'string',
            },
          },
        },
        Error: {
          type: 'object',
          properties: {
            message: {
              type: 'string',
              description: 'Message describing the error.',
              example: 'A brief description of the error.',
            },
            errorCode: {
              type: 'number',
              description: 'A 5-digit error code uniquely identifying this particular type of error.\n',
              example: 40149,
            },
          },
        },
      },
    },
    security: [
      {
        apiKeyAuth: [],
      },
    ],
    paths: {
      '/vault/{filename}': {
        get: Get {
          tags: [
            'Vault Files',
          ],
          summary: 'Return the content of a single file in your vault.\n',
          operationId: 'get_vault_filename',
          description: 'Returns the content of the specified file if it exists. Use `Accept: application/vnd.olrapi.note+json` to receive a JSON representation including tags, frontmatter and metadata.\n',
          parameters+: [ParamPath],
        },
        put: Put {
          tags: [
            'Vault Files',
          ],
          summary: 'Create a new file in your vault or update the content of an existing one.\n',
          operationId: 'put_vault_filename',
          description: 'Creates a new file in your vault or updates the content of an existing one if the specified file already exists.\n',
          parameters+: [ParamPath],
        },
        post: Post {
          tags: [
            'Vault Files',
          ],
          summary: 'Append content to a new or existing file.\n',
          operationId: 'post_vault_filename',
          description: "Appends content to the end of an existing note. If the specified file does not yet exist, it will be created as an empty file.\n\nIf you would like to insert text relative to a particular heading, block reference, or frontmatter field instead of appending to the end of the file, see 'patch'.\n",
          parameters+: [ParamPath],
        },
        patch: Patch {
          tags: [
            'Vault Files',
          ],
          summary: 'Partially update content in an existing note.\n',
          operationId: 'patch_vault_filename',
          description: 'Inserts content into an existing note relative to a heading, block refeerence, or frontmatter field within that document.\n\n' + Patch.description,
          parameters+: [ParamPath],
        },
        delete: Delete {
          tags: [
            'Vault Files',
          ],
          summary: 'Delete a particular file in your vault.\n',
          operationId: 'delete_vault_filename',
          parameters: Delete.parameters + [ParamPath],
        },
      },
      '/vault/': {
        get: {
          tags: [
            'Vault Directories',
          ],
          summary: 'List files that exist in the root of your vault.\n',
          operationId: 'get_vault',
          description: 'Lists files in the root directory of your vault.\n\nNote: that this is exactly the same API endpoint as the below "List files that exist in the specified directory." and exists here only due to a quirk of this particular interactive tool.\n',
          responses: {
            '200': {
              description: 'Success',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      files: {
                        type: 'array',
                        items: {
                          type: 'string',
                        },
                      },
                    },
                  },
                  example: {
                    files: [
                      'mydocument.md',
                      'somedirectory/',
                    ],
                  },
                },
              },
            },
            '404': {
              description: 'Directory does not exist',
              content: {
                'application/json': {
                  schema: {
                    '$ref': '#/components/schemas/Error',
                  },
                },
              },
            },
          },
        },
      },
      '/vault/{pathToDirectory}/': {
        get: {
          tags: [
            'Vault Directories',
          ],
          summary: 'List files that exist in the specified directory.\n',
          operationId: 'get_vault_pathToDirectory',
          parameters: [
            {
              name: 'pathToDirectory',
              'in': 'path',
              description: 'Path to list files from (relative to your vault root).  Note that empty directories will not be returned.\n\nNote: this particular interactive tool requires that you provide an argument for this field, but the API itself will allow you to list the root folder of your vault. If you would like to try listing content in the root of your vault using this interactive tool, use the above "List files that exist in the root of your vault" form above.\n',
              required: true,
              schema: {
                type: 'string',
                format: 'path',
              },
            },
          ],
          responses: {
            '200': {
              description: 'Success',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      files: {
                        type: 'array',
                        items: {
                          type: 'string',
                        },
                      },
                    },
                  },
                  example: {
                    files: [
                      'mydocument.md',
                      'somedirectory/',
                    ],
                  },
                },
              },
            },
            '404': {
              description: 'Directory does not exist',
              content: {
                'application/json': {
                  schema: {
                    '$ref': '#/components/schemas/Error',
                  },
                },
              },
            },
          },
        },
      },
      '/periodic/{period}/': {
        get: Get {
          tags: [
            'Periodic Notes',
          ],
          summary: 'Get current periodic note for the specified period.\n',
          operationId: 'get_periodic_period',
          parameters+: [ParamPeriod],
        },
        put: Put {
          tags: [
            'Periodic Notes',
          ],
          summary: 'Update the content of the current periodic note for the specified period.\n',
          operationId: 'put_periodic_period',
          parameters+: [ParamPeriod],
        },
        post: Post {
          tags: [
            'Periodic Notes',
          ],
          summary: 'Append content to the current periodic note for the specified period.\n',
          operationId: 'post_periodic_period',
          description: 'Note that this will create the relevant periodic note if necessary.\n',
          parameters+: [ParamPeriod],
        },
        patch: Patch {
          tags: [
            'Periodic Notes',
          ],
          summary: 'Partially update content in the current periodic note for the specified period.\n',
          operationId: 'patch_periodic_period',
          description: 'Insert content into the current periodic note for the specified period relative to a heading, block reference, or frontmatter field. See plugin documentation for examples.',
          parameters+: [ParamPeriod],
        },
        delete: Delete {
          tags: [
            'Periodic Notes',
          ],
          summary: 'Delete the current periodic note for the specified period.\n',
          operationId: 'delete_periodic_period',
          parameters+: [ParamPeriod],
        },
      },
      '/periodic/{period}/{year}/{month}/{day}/': {
        get: Get {
          tags: [
            'Periodic Notes',
          ],
          summary: 'Get the periodic note for the specified period and date.\n',
          operationId: 'get_periodic_period_year_month_day',
          parameters+: [ParamYear, ParamMonth, ParamDay, ParamPeriod],
        },
        put: Put {
          tags: [
            'Periodic Notes',
          ],
          summary: 'Update the content of the periodic note for the specified period and date.\n',
          operationId: 'put_periodic_period_year_month_day',
          parameters+: [ParamYear, ParamMonth, ParamDay, ParamPeriod],
        },
        post: Post {
          tags: [
            'Periodic Notes',
          ],
          summary: 'Append content to the periodic note for the specified period and date.\n',
          operationId: 'post_periodic_period_year_month_day',
          description: 'This will create the relevant periodic note if necessary.\n',
          parameters+: [ParamYear, ParamMonth, ParamDay, ParamPeriod],
        },
        patch: Patch {
          tags: [
            'Periodic Notes',
          ],
          summary: 'Partially update content in the periodic note for the specified period and date.\n',
          operationId: 'patch_periodic_period_year_month_day',
          description: 'Inserts content into a periodic note relative to a heading, block refeerence, or frontmatter field within that document.\n\n' + Patch.description,
          parameters+: [ParamYear, ParamMonth, ParamDay, ParamPeriod],
        },
        delete: Delete {
          tags: [
            'Periodic Notes',
          ],
          summary: 'Delete the periodic note for the specified period and date.\n',
          description: 'Deletes the periodic note for the specified period.\n',
          operationId: 'delete_periodic_period_year_month_day',
          parameters+: [ParamYear, ParamMonth, ParamDay, ParamPeriod],
        },
      },
      '/commands/': {
        get: {
          tags: [
            'Commands',
          ],
          summary: 'Get a list of available commands.\n',
          operationId: 'get_commands',
          responses: {
            '200': {
              description: 'A list of available commands.',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      commands: {
                        type: 'array',
                        items: {
                          type: 'object',
                          properties: {
                            id: {
                              type: 'string',
                            },
                            name: {
                              type: 'string',
                            },
                          },
                        },
                      },
                    },
                  },
                  example: {
                    commands: [
                      {
                        id: 'global-search:open',
                        name: 'Search: Search in all files',
                      },
                      {
                        id: 'graph:open',
                        name: 'Graph view: Open graph view',
                      },
                    ],
                  },
                },
              },
            },
          },
        },
      },
      '/commands/{commandId}/': {
        post: {
          tags: [
            'Commands',
          ],
          summary: 'Execute a command.\n',
          operationId: 'post_commands_commandId',
          parameters: [
            {
              name: 'commandId',
              'in': 'path',
              description: 'The id of the command to execute',
              required: true,
              schema: {
                type: 'string',
              },
            },
          ],
          responses: {
            '204': {
              description: 'Success',
            },
            '404': {
              description: 'The command you specified does not exist.',
              content: {
                'application/json': {
                  schema: {
                    '$ref': '#/components/schemas/Error',
                  },
                },
              },
            },
          },
        },
      },
      '/search/': {
        post: {
          tags: [
            'Search',
          ],
          summary: 'Search for documents matching a specified search query\n',
          operationId: 'post_search',
          description: 'Evaluate a query against files in your vault. Provide the query in the request body using either Dataview DQL or JSON Logic, chosen via the `Content-Type` header.\n',
          requestBody: {
            required: true,
            content: {
              'application/vnd.olrapi.dataview.dql+txt': {
                schema: {
                  type: 'object',
                  externalDocs: {
                    url: 'https://blacksmithgu.github.io/obsidian-dataview/query/queries/',
                  },
                },
                examples: {
                  find_fields_by_tag: {
                    summary: 'List data from files having the #game tag.',
                    value: 'TABLE\n  time-played AS "Time Played",\n  length AS "Length",\n  rating AS "Rating"\nFROM #game\nSORT rating DESC\n',
                  },
                },
              },
              'application/vnd.olrapi.jsonlogic+json': {
                schema: {
                  type: 'object',
                  externalDocs: {
                    url: 'https://jsonlogic.com/operations.html',
                  },
                },
                examples: {
                  find_by_frontmatter_value: {
                    summary: 'Find notes having a certain frontmatter field value.',
                    value: '{\n  "==": [\n    {"var": "frontmatter.myField"},\n    "myValue"\n  ]\n}\n',
                  },
                  find_by_frontmatter_url_glob: {
                    summary: 'Find notes having URL or a matching URL glob frontmatter field.',
                    value: '{\n  "or": [\n    {"===": [{"var": "frontmatter.url"}, "https://myurl.com/some/path/"]},\n    {"glob": [{"var": "frontmatter.url-glob"}, "https://myurl.com/some/path/"]}\n  ]\n}\n',
                  },
                  find_by_tag: {
                    summary: 'Find notes having a certain tag',
                    value: '{\n  "in": [\n    "myTag",\n    {"var": "tags"}\n  ]\n}\n',
                  },
                },
              },
            },
          },
          responses: {
            '200': {
              description: 'Success',
              content: {
                'application/json': {
                  schema: {
                    type: 'array',
                    items: {
                      type: 'object',
                      required: [
                        'filename',
                        'result',
                      ],
                      properties: {
                        filename: {
                          type: 'string',
                          description: 'Path to the matching file',
                        },
                        result: {
                          oneOf: [
                            {
                              type: 'string',
                            },
                            {
                              type: 'number',
                            },
                            {
                              type: 'array',
                            },
                            {
                              type: 'object',
                            },
                            {
                              type: 'boolean',
                            },
                          ],
                        },
                      },
                    },
                  },
                },
              },
            },
            '400': {
              description: 'Bad request.  Make sure you have specified an acceptable\nContent-Type for your search query.\n',
              content: {
                'application/json': {
                  schema: {
                    '$ref': '#/components/schemas/Error',
                  },
                },
              },
            },
          },
        },
      },
      '/search/simple/': {
        post: {
          tags: [
            'Search',
          ],
          summary: 'Search for documents matching a specified text query\n',
          operationId: 'post_search_simple',
          parameters: [
            {
              name: 'query',
              'in': 'query',
              description: 'Your search query',
              required: true,
              schema: {
                type: 'string',
              },
            },
            {
              name: 'contextLength',
              'in': 'query',
              description: 'How much context to return around the matching string',
              required: false,
              schema: {
                type: 'number',
                default: 100,
              },
            },
          ],
          responses: {
            '200': {
              description: 'Success',
              content: {
                'application/json': {
                  schema: {
                    type: 'array',
                    items: {
                      type: 'object',
                      properties: {
                        filename: {
                          type: 'string',
                          description: 'Path to the matching file',
                        },
                        score: {
                          type: 'number',
                        },
                        matches: {
                          type: 'array',
                          items: {
                            type: 'object',
                            required: [
                              'match',
                              'context',
                            ],
                            properties: {
                              match: {
                                type: 'object',
                                required: [
                                  'start',
                                  'end',
                                ],
                                properties: {
                                  start: {
                                    type: 'number',
                                  },
                                  end: {
                                    type: 'number',
                                  },
                                },
                              },
                              context: {
                                type: 'string',
                              },
                            },
                          },
                        },
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
      '/open/{filename}': {
        post: {
          tags: [
            'Open',
          ],
          summary: 'Open the specified document in the Obsidian user interface.\n',
          operationId: 'post_open_filename',
          description: 'Note: Obsidian will create a new document at the path you have\nspecified if such a document did not already exist.\n',
          parameters: [
            {
              name: 'filename',
              'in': 'path',
              description: 'Path to the file to return (relative to your vault root).\n',
              required: true,
              schema: {
                type: 'string',
                format: 'path',
              },
            },
            {
              name: 'newLeaf',
              'in': 'query',
              description: 'Open this as a new leaf?',
              required: false,
              schema: {
                type: 'boolean',
              },
            },
          ],
          responses: {
            '200': {
              description: 'Success',
            },
          },
        },
      },
      '/': {
        get: {
          tags: [
            'System',
          ],
          summary: 'Returns basic details about the server.\n',
          operationId: 'get_root',
          description: 'Returns basic details about the server as well as your authentication status.\n\nThis is the only API request that does *not* require authentication.\n',
          responses: {
            '200': {
              description: 'Success',
              content: {
                'application/json': {
                  schema: {
                    type: 'object',
                    properties: {
                      ok: {
                        type: 'string',
                        description: "'OK'",
                      },
                      versions: {
                        type: 'object',
                        properties: {
                          obsidian: {
                            type: 'string',
                            description: 'Obsidian plugin API version',
                          },
                          'self': {
                            type: 'string',
                            description: 'Plugin version.',
                          },
                        },
                      },
                      service: {
                        type: 'string',
                        description: "'LLM Bridges for Obsidian'",
                      },
                      authenticated: {
                        type: 'boolean',
                        description: 'Is your current request authenticated?',
                      },
                    },
                  },
                },
              },
            },
          },
        },
      },
      '/openapi.yaml': {
        get: {
          tags: [
            'System',
          ],
          summary: 'Returns OpenAPI YAML document describing the capabilities of this API.\n',
          operationId: 'get_openapiyaml',
          responses: {
            '200': {
              description: 'Success',
            },
          },
        },
      },
      '/obsidian-local-rest-api.crt': {
        get: {
          tags: [
            'System',
          ],
          summary: 'Returns the certificate in use by this API.\n',
          operationId: 'get_obsidian_local_rest_apicrt',
          responses: {
            '200': {
              description: 'Success',
            },
          },
        },
      },
    },
  },
  quote_keys=false,
  indent_array_in_object=true,
)
