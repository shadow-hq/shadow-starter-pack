use alloy_dyn_abi::DynSolType;
use alloy_json_abi::EventParam;
use ethabi::ParamType;

/// Trait to convert to an [`ethabi::ParamType`]
pub trait ToEthAbiParamType {
    fn to_eth_abi_param_type(&self) -> Result<ParamType, Box<dyn std::error::Error>>;
}

/// Trait to convert an [`alloy_json_abi::EventParam`] to an [`ethabi::ParamType`].
///
/// We do this so that we can use the ethabi library to decode events.
impl ToEthAbiParamType for EventParam {
    fn to_eth_abi_param_type(&self) -> Result<ParamType, Box<dyn std::error::Error>> {
        let dyn_sol_type = self.to_dyn_sol_type()?;
        dyn_sol_type.to_eth_abi_param_type()
    }
}

/// Trait to convert an [`alloy_dyn_abi::DynSolType`] to an [`ethabi::ParamType`].
/// Used by the [`alloy_json_abi::EventParam`] [`ToEthAbiParamType`] trait.
///
/// This is a hack.
///
/// It's much easier to do the conversion:
/// [`alloy_json_abi::EventParam`] -> [`alloy_dyn_abi::DynSolType`] -> [`ethabi::ParamType`].
///
/// It's more difficult to directly do the conversion:
/// [`alloy_json_abi::EventParam`] -> [`ethabi::ParamType`].
///
/// We can remove this hack once we have a way to decode complex structs using
/// the [`alloy_dyn_abi`] library.
impl ToEthAbiParamType for DynSolType {
    fn to_eth_abi_param_type(&self) -> Result<ParamType, Box<dyn std::error::Error>> {
        match self {
            DynSolType::Address => Ok(ParamType::Address),
            DynSolType::Bool => Ok(ParamType::Bool),
            DynSolType::Bytes => Ok(ParamType::Bytes),
            DynSolType::Int(size) => Ok(ParamType::Int(*size)),
            DynSolType::String => Ok(ParamType::String),
            DynSolType::Uint(size) => Ok(ParamType::Uint(*size)),
            DynSolType::Array(sol_type) => {
                let param_type = sol_type.to_eth_abi_param_type()?;
                Ok(ParamType::Array(Box::new(param_type)))
            }
            DynSolType::FixedBytes(size) => Ok(ParamType::FixedBytes(*size)),
            DynSolType::FixedArray(sol_type, size) => {
                let param_type = sol_type.to_eth_abi_param_type()?;
                Ok(ParamType::FixedArray(Box::new(param_type), *size))
            }
            DynSolType::Tuple(sol_type) => {
                let mut param_types = Vec::new();
                for sol_type in sol_type {
                    let param_type = sol_type.to_eth_abi_param_type()?;
                    param_types.push(param_type);
                }
                Ok(ParamType::Tuple(param_types))
            }
            DynSolType::CustomStruct {
                name: _,
                prop_names: _,
                tuple,
            } => {
                let mut param_types = Vec::new();
                for sol_type in tuple {
                    let param_type = sol_type.to_eth_abi_param_type()?;
                    param_types.push(param_type);
                }
                Ok(ParamType::Tuple(param_types))
            }
            DynSolType::Function => Err("Function type not supported".into()),
        }
    }
}

/// Trait to convert to a [`DynSolType`]
pub trait ToDynSolType {
    fn to_dyn_sol_type(&self) -> Result<DynSolType, Box<dyn std::error::Error>>;
}

/// Trait to convert an [`alloy_json_abi::EventParam`] to a [`DynSolType`].
/// Used by the [`alloy_json_abi::EventParam`] [`ToEthAbiParamType`] trait.
///
/// This uses the [`alloy_dyn_abi`] library to convert from an [`alloy_json_abi::EventParam`].
/// The [`alloy_dyn_abi`] library contains a `parse` method that can parse a string into a
/// [`DynSolType`].
///
/// We add some extra logic to handle the case where the [`alloy_json_abi::EventParam`] is a
/// complex struct or an array.
impl ToDynSolType for EventParam {
    fn to_dyn_sol_type(&self) -> Result<DynSolType, Box<dyn std::error::Error>> {
        if !self.components.is_empty() {
            let mut tuple_parts = Vec::new();
            for component in self.components.iter() {
                let dyn_sol_type = component.to_dyn_sol_type()?;
                tuple_parts.push(dyn_sol_type);
            }
            if self.ty.ends_with("[]") {
                Ok(DynSolType::Array(Box::new(DynSolType::Tuple(tuple_parts))))
            } else {
                Ok(DynSolType::Tuple(tuple_parts))
            }
        } else {
            let dyn_sol_type: DynSolType = self.ty.parse()?;
            Ok(dyn_sol_type)
        }
    }
}

impl ToDynSolType for alloy_json_abi::Param {
    fn to_dyn_sol_type(&self) -> Result<DynSolType, Box<dyn std::error::Error>> {
        if !self.components.is_empty() {
            let mut tuple_parts = Vec::new();
            for component in self.components.iter() {
                let dyn_sol_type = component.to_dyn_sol_type()?;
                tuple_parts.push(dyn_sol_type);
            }
            if self.ty.ends_with("[]") {
                Ok(DynSolType::Array(Box::new(DynSolType::Tuple(tuple_parts))))
            } else {
                Ok(DynSolType::Tuple(tuple_parts))
            }
        } else {
            let dyn_sol_type: DynSolType = self.ty.parse()?;
            Ok(dyn_sol_type)
        }
    }
}
