class UiController < ApplicationController
  def index
    @api = params[:api]
  end

  def fm_config
    render json: {'config_format_version' => 1, 'addresses' =>
        {
            '123.23,-345.01' =>
               {country: 'Japan',
                pref: 'Fukushima Prefecture',
                city: 'Inawashiro',
                formattedAddresses: [
                    'Ban-etsu Expressway, Sarashina, Bandai, Yama District, Fukushima Prefecture, Japan',
                    'Iwane, Inawashiro, Yama District, Fukushima Prefecture 969-3286, Japan',
                    'Sarashina, Bandai, Yama District, Fukushima Prefecture, Japan',
                    'Sarashina, Bandai, Yama District, Fukushima Prefecture 969-3302, Japan'

                ]
               },
            '-156.33,89.00' =>
                {country: 'Italy',
                 pref: 'Lazio',
                 city: 'Rome',
                 formattedAddresses: [
                     'Via dei Fori Imperiali, Rome, Italy',
                     '00186 Rome, Italy',
                     'Rome, Province of Rome, Italy'
                 ]
                }
        }}
  end
end
