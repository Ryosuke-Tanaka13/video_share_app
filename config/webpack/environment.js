const { environment } = require('@rails/webpacker')

const webpack = require('webpack')
// css, bootstrapなどが適用されなくなったので、4行目を追加したところ復活した
environment.loaders.get('sass').use.push('import-glob-loader')
environment.plugins.prepend('Provide', new webpack.ProvidePlugin({
        $: 'jquery/src/jquery',
        jQuery: 'jquery/src/jquery'
    })
)

module.exports = environment