/*
 * czJsDocShowcase. V1.0b
 *
 * Author & Copyright (c) 2021. César Pedro Zea Gómez <cesarzea@jaunesistemas.com>
 * Contact to request your 'free' license, any question or request or to hire me as a freelancer (freelance from 1999)
 *
 * More information at : https://www.cesarzea.com
 * Documentation       : https://www.cesarzea.com/czJsDocShowcase
 * GitHub repo         : https://github.com/cesarzea/czJsDocShowcase
 *
 * Please, use the issues section of the Git repository to report bugs or request improvements.
 *
 */
czJsDocShowcase.app.mainConfig = {

    /**
     * pageTitle: Page title.
     */
    pageTitle: 'César Zea - SQL Server T-SQL Advanced Asynchronous programming.',

    /**
     * topBarTitle: the title thar is shown in the top bar of the page.
     */
    topBarTitle: 'César Zea - SQL Server T-SQL Advanced Asynchronous programming.',

    /**
     * treeBarTitle: The label that is displayed above the content tree.
     */
    treeBarTitle: 'Documentation',

    /**
     * treeBarWidth: The initial width of the three bar contents.
     */
    treeBarWidth: 400,

    /**
     * treeBarCollapsed: true if you want the tree content start collapsed or expanded.
     * If the width of the window is too small, the tree content will be started collapsed.
     */
    treeBarCollapsed: false,

    /**
     * stylesToLoad: one array with a list of css files you want to be loaded at start up.
     * That is very useful to change the the appearance of the presentation, create
     * new markdown style elements, the style of new plugins, etc.
     */
    stylesToLoad: [
        '../data/css/styles.css',
        '../data/css/jsdocStyles.css',
        '../data/extend/markdown_extend_blockquotes.css',
        'https://vjs.zencdn.net/7.11.4/video-js.css'
    ],

    /**
     * Only relevant to include Sencha ExtJs components or new components based on Sencha ExtJs.
     * Define the paths config variable for the Ext.Loader singleton.
     * See https://docs.sencha.com/extjs/7.3.1/modern/Ext.Loader.html#cfg-paths.
     */
    namespaceMapping: {

    },

    /**
     * scriptsToLoad: an Array of JavaScripts files to be loaded at start up.
     */
    scriptsToLoad: [
        '../data/extend/markdown_extend.js',
    ],

    /**
     * The icon that will be displayed in all nodes that not specified what icon to show
     * in the iconCls value.
     */
    defaultNodeIcon: 'fas fa-circle fa-sm',

    /**
     * Document list to include in the contents.
     * Read the specific documentation for that
     * config variable at User Manual > docsToLoad: including your documents
     */
    docsToLoad: [
        {
            type: 'markdown',
            name: 'What is that?',
            file: '../data/docs/1. What is that.md',
            iconCls: 'far fa-question-circle',
            levelsToShowInTree: 2,
            default: true
        },



        {
            type: 'markdown',
            name: 'Use cases solved',
            file: '../data/docs/2. Use Cases in psuedocode.md',
            iconCls: 'far fa-question-circle',
            levelsToShowInTree: 2
        },


        //--------------------------------------------------
        //--------------------------------------------------

        //--------------------------------------------------
        {
            type: 'namespace',
            name: 'Documentation',
            iconCls: 'far fa-question-circle'
        },

        {
            type: 'markdown',
            name: 'st_czAsyncExecInvoke',
            file: '../data/docs/doc_intro.md',
            iconCls: 'fas fa-circle fa-sm',
            levelsToShowInTree: 2,
            memberOf:'Documentation',
        },

        {
            type: 'markdown',
            name: 'czAsyncExecResults',
            file: '../data/docs/czAsyncExecResults.md',
            iconCls: 'fas fa-circle fa-sm',
            levelsToShowInTree: 2,
            memberOf:'Documentation',
        },



/*
        {
            type: 'namespace',
            name: 'Reference guide',
            iconCls: 'far fa-question-circle',
            memberOf: 'Documentation'
        },
       */


        {
            type: 'markdown',
            name: 'Installation guide',
            file: '../data/docs/Step by Step guide.md',
            iconCls: 'far fa-question-circle',
            levelsToShowInTree: 2
        }
    ]
}

