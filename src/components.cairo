use array::ArrayTrait;
use starknet::ContractAddress;
use debug::PrintTrait;
use integer::{U8IntoFelt252, Felt252TryIntoU8};
use option::OptionTrait;
use traits::{Into, TryInto};

const BOARD_WIDTH: u8 = 7;

#[derive(Copy, Drop, Serde, PartialEq)]
enum PieceColor {
    White: (),
    Black: (),
}

impl PieceColorPrintTrait of PrintTrait<PieceColor> {
    #[inline(always)]
    fn print(self: PieceColor) {
        match self {
            PieceColor::White(_) => {
                'White'.print();
            },
            PieceColor::Black(_) => {
                'Black'.print();
            },
        }
    }
}

impl PieceColorSerdeLen of dojo::SerdeLen<PieceColor> {
    #[inline(always)]
    fn len() -> usize {
        1
    }
}

impl OptionPieceColorSerdeLen of dojo::SerdeLen<Option<PieceColor>> {
    #[inline(always)]
    fn len() -> usize {
        1
    }
}

#[derive(Component, Copy, Drop, Serde, SerdeLen)]
struct Piece {
    piece_id: felt252,
    color: PieceColor,
}

#[derive(Component, Copy, Drop, Serde, SerdeLen, PartialEq)]
struct Position {
    x: u8,
    y: u8
}

impl IntoU8ToPositionImpl of Into<Position, u8> {
    fn into(self: Position) -> u8 {
        self.y * BOARD_WIDTH + self.x
    }
}

impl IntoPositionToU8Impl of Into<u8, Position> {
    fn into(self: u8) -> Position {
        let y = self / BOARD_WIDTH;
        let x = self % BOARD_WIDTH;
        Position { x, y }
    }
}

impl IntoFelt252ToPositionImpl of Into<Position, felt252> {
    fn into(self: Position) -> felt252 {
        let self_u8: u8 = self.into();
        self_u8.into()
    }
}

impl IntoPositionToFelt252Impl of Into<felt252, Position> {
    fn into(self: felt252) -> Position {
        let self_u8: u8 = self.try_into().unwrap();
        self.into()
    }
}

#[derive(Component, Copy, Drop, Serde, SerdeLen)]
struct PlayersId {
    white: ContractAddress,
    black: ContractAddress,
}

#[derive(Component, Copy, Drop, Serde, SerdeLen)]
struct Game {
    status: bool,
    winner: Option<PieceColor>,
}


#[derive(Component, Copy, Drop, Serde, SerdeLen)]
struct GameTurn {
    turn: PieceColor, 
}
