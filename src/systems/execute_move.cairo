use core::result::ResultTrait;
#[system]
mod execute_move_system {
    use array::ArrayTrait;
    use traits::Into;
    use dojo::world::Context;
    use starknet::ContractAddress;
    use four_connect_dojo::components::{Position, Piece, PieceColor, Game, GameTurn, PlayersId};
    use debug::PrintTrait;
    use cmp::{min, max};

    fn execute(ctx: Context, game_id: felt252, column: u8, caller: ContractAddress) {
        let current_game_turn = get !(ctx.world, game_id.into(), (GameTurn));
        let player_id = get !(ctx.world, game_id.into(), (PlayersId));

        // Find all pieces position
        let (pieces) = find !(ctx.world, 0x0, (Piece));
        let mut board = ArrayTrait::<Span<Option<Piece>>>::new();

        // loop through the rows
        let mut row = 0;
        loop {
            if row == 7 {
                break ();
            }

            // generate the row array
            let mut board_row = ArrayTrait::<Option<Piece>>::new();

            // loop through the row columns
            let mut col = 0;
            loop {
                if col == 6 {
                    break ();
                }

                // find the pieces that match the current row and col
                let mut j = 0;
                let mut add_piece = Option::None(());
                loop {
                    if j == pieces.len() {
                        break ();
                    }

                    let piece = *pieces.at(j);
                    let position = get !(ctx.world, piece.piece_id.into(), (Position));

                    if position.x == col && position.y == row {
                        add_piece = Option::Some(piece);
                    }

                    j += 1;
                };
                board_row.append(add_piece);
                col += 1;
            };
            board.append(board_row.span());
            row += 1;
        };

        // check if the next_position is valid
        let row = find_available_row(column, board.span());
        // Legal moves
        assert(row.is_none(), 'Not a valid move');
        let new_position = Position { x: column, y: row.unwrap() };

        // check if it is the caller's turn
        if player_id.white == caller {
            assert(current_game_turn.turn == PieceColor::White(()), 'Not your turn');
        } else {
            assert(current_game_turn.turn == PieceColor::Black(()), 'Not your turn');
        };

        // add piece
        set !(
            ctx.world,
            new_position.into(),
            (
                Piece {
                    piece_id: new_position.into(), color: current_game_turn.turn, 
                }, new_position,
            )
        );

        let next_turn = match current_game_turn.turn {
            PieceColor::White(()) => PieceColor::Black(()),
            PieceColor::Black(()) => PieceColor::White(()),
        };
        set !(ctx.world, game_id.into(), (GameTurn { turn: next_turn }, ));
        return ();
    }

    fn find_available_row(column: u8, board: Span<Span<Option<Piece>>>) -> Option<u8> {
        let column = *board.at(column.into());
        let mut row: u8 = 0;
        loop {
            if row > 5 {
                break Option::None(());
            }
            let piece = *column.at(row.into());
            if piece.is_none() {
                break Option::Some(row);
            }
            row += 1;
        }
    }

    fn check_win(
        piece_color: PieceColor, position: Position, board: Span<Span<Option<Piece>>>
    ) -> bool {
        // Check horizontal
        let mut idx = 0;
        let mut count = 0;
        loop {
            if idx == 7 {
                break;
            }
            let maybe_piece = *(*board.at(position.y.into())).at(idx);
            if !maybe_piece.is_none() {
                if (maybe_piece.unwrap().color == piece_color) {
                    count += 1;
                    if (count == 4) {
                        break;
                    }
                }
            }
            count = 0;
            idx += 1;
        };

        if (count == 4) {
            return true;
        }
        count = 0;

        // Check vertical
        loop {
            if idx == 6 {
                break;
            }
            let maybe_piece = *(*board.at(idx)).at(position.x.into());
            if !maybe_piece.is_none() {
                if (maybe_piece.unwrap().color == piece_color) {
                    count += 1;
                    if (count == 4) {
                        break;
                    }
                }
            }
            count = 0;
            idx += 1;
        };
        if (count == 4) {
            return true;
        }
        count = 0;

        // Check diagonal (top-left to bottom-right)
        let mut start_row = position.y - min(position.x, position.y);
        let mut start_column = position.x - min(position.x, position.y);

        loop {
            if start_row == 6 || start_column == 7 {
                break;
            }
            let maybe_piece = *(*board.at(start_row.into())).at(start_column.into());
            if !maybe_piece.is_none() {
                if (maybe_piece.unwrap().color == piece_color) {
                    count += 1;
                    if (count == 4) {
                        break;
                    }
                }
            }
            count = 0;
            start_row += 1;
            start_column += 1;
        };

        if (count == 4) {
            return true;
        }
        count = 0;

        // Check diagonal (top-right to bottom-left)
        let mut start_row = position.y + min(7 - 1 - position.x, position.y);
        let mut start_column = position.x - min(7 - 1 - position.x, position.y);

        loop {
            if start_row == 6 || start_column == 7 {
                break;
            }
            let maybe_piece = *(*board.at(start_row.into())).at(start_column.into());
            if !maybe_piece.is_none() {
                if (maybe_piece.unwrap().color == piece_color) {
                    count += 1;
                    if (count == 4) {
                        break;
                    }
                }
            }
            count = 0;
            start_row += 1;
            start_column += 1;
        };

        if (count == 4) {
            return true;
        }

        false
    }
}
