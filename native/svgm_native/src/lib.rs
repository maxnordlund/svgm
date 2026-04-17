use std::collections::HashMap;

use rustler::{NifException, NifResult, NifStruct, NifUnitEnum, NifUntaggedEnum};

#[derive(Debug, NifUnitEnum)]
enum ConfigPreset {
    Safe,
    Default,
}

impl From<ConfigPreset> for svgm_core::Preset {
    fn from(preset: ConfigPreset) -> Self {
        match preset {
            ConfigPreset::Safe => svgm_core::Preset::Safe,
            ConfigPreset::Default => svgm_core::Preset::Default,
        }
    }
}

#[derive(NifException)]
#[module = "SVGM.Exceptions.XMLParseError"]
struct XMLParseError {
    message: String,
}

#[derive(NifException)]
#[module = "SVGM.Exceptions.UnexpectedEOFError"]
struct UnexpectedEOFError {
    message: String,
}

#[derive(NifException)]
#[module = "SVGM.Exceptions.MismatchedTagError"]
struct MismatchedTagError {
    message: String,
    expected: String,
    found: String,
}

#[derive(NifUntaggedEnum)]
enum ParseError {
    Xml(XMLParseError),
    UnexpectedEof(UnexpectedEOFError),
    MismatchedTag(MismatchedTagError),
}

impl From<svgm_core::parser::ParseError> for ParseError {
    fn from(error: svgm_core::parser::ParseError) -> Self {
        let message = error.to_string();
        match error {
            svgm_core::parser::ParseError::Xml {
                position: _,
                message: _,
            } => ParseError::Xml(XMLParseError { message }),
            svgm_core::parser::ParseError::MismatchedTag { expected, found } => {
                ParseError::MismatchedTag(MismatchedTagError {
                    message,
                    expected,
                    found,
                })
            }
            svgm_core::parser::ParseError::UnexpectedEof => {
                ParseError::UnexpectedEof(UnexpectedEOFError { message })
            }
        }
    }
}

#[derive(Debug, NifStruct)]
#[module = "SVGM.Options"]
struct Options {
    preset: ConfigPreset,
    precision: Option<u32>,
    pass_overrides: HashMap<String, bool>,
}

#[rustler::nif]
fn optimize(svg: &str, options: Options) -> NifResult<String> {
    let config = &svgm_core::Config {
        preset: options.preset.into(),
        precision: options.precision,
        pass_overrides: options.pass_overrides,
    };

    match svgm_core::optimize_with_config(svg, config) {
        Ok(output) => Ok(output.data),
        Err(err) => {
            let exception: ParseError = err.into();
            Err(rustler::Error::RaiseTerm(Box::new(exception)))
        }
    }
}

rustler::init!("Elixir.SVGM.Native");
