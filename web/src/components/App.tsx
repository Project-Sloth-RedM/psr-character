import React, { useEffect, useState } from 'react';
import './App.css';
import { fetchNui } from '../utils/fetchNui';
import { debugData } from '../utils/debugData';
import {
	IoAddCircle,
	IoBody,
	IoCaretBack,
	IoCaretForward,
	IoFootsteps,
	IoGlasses,
	IoTrash,
} from 'react-icons/io5';
import { useNuiEvent } from '../hooks/useNuiEvent';

debugData([
	{
		action: 'setVisible',
		data: true,
	},
]);

interface Idata {
	id: number | string;
	type: string;
	label: string;
	values: string[] | number[];
	value: number;
}

interface IinitialData {
	cloth: any[];
	title: string;
	desc?: string;
}

interface IcharacterData {
	characters: Ichar[];
	canCreate: boolean;
}

interface IspawnData {
	locations: any[];
	title: string;
}

interface Ichar {
	name: string;
	cid: string;
	data: any[];
}

// [
// 	{
// 		id: 1,
// 		label: 'Clothing Label 1',
// 		values: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
// 		value: 0,
// 	}
// ]

const App: React.FC = () => {
	const [menu, setMenu] = useState<string>('charMenu');

	const [characters, setCharacters] = useState<Ichar[]>([]);
	const [canCreateNew, setCanCreateNew] = useState<boolean>(true);
	const [deleteModal, setDeleteModal] = useState<boolean>(false);
	const [newCharModal, setNewCharModal] = useState<boolean>(false);
	const [deleteData, setDeleteData] = useState<Ichar>();

	const [inputFirstname, setInputFirstnamne] = useState<string>('John');
	const [inputLastname, setInputLastnamne] = useState<string>('Doe');
	const [inputDOB, setInputDOB] = useState<string>('1890-01-01');
	const [inputGender, setInputGender] = useState<string>('Male');

	const [data, setData] = useState<Idata[]>([]);
	const [spawnData, setSpawnData] = useState<IspawnData[]>([]);
	const [title, setTitle] = useState<string>('');
	const [description, setDescription] = useState<string>('');

	useEffect(() => {
		const temp = [
			{
				name: 'John Doe',
				cid: 'CID-012319809',
				data: [],
			},
			{
				name: 'John Doe',
				cid: 'CID-012319809',
				data: [],
			},
			{
				name: 'John Doe',
				cid: 'CID-012319809',
				data: [],
			},
		];

		setCharacters(temp);
	}, []);

	useNuiEvent<IinitialData>('setInitialData', (data) => {
		setData(data.cloth);
		setTitle(data.title);
		if (data.desc) setDescription(data.desc);
	});

	useNuiEvent<IspawnData>('setSpawnData', (data) => {
		setSpawnData(data.locations);
		setTitle(data.title);
	});

	useNuiEvent<string>('setMenu', (data) => {
		setMenu(data);
	});

	useNuiEvent('resetModals', () => {
		setDeleteModal(false);
		setNewCharModal(false);
	});

	useNuiEvent<IcharacterData>('setCharacters', (data) => {
		setCharacters(data.characters);
		setCanCreateNew(data.canCreate);
	});

	const handleArrowClick = (type: string, id: number) => {
		const tempArr = [...data];

		tempArr.map((item) => {
			if (item.id === id) {
				if (type === 'decrease') {
					if (item.value > 0) item.value--;
					setData(tempArr);
					fetchNui('updateMenuVariable', { type, id });
				}
				if (type === 'increase') {
					if (item.value < item.values.length) item.value++;
					setData(tempArr);
					fetchNui('updateMenuVariable', { type, id });
				}
			}
		});
	};

	const handleDeleteClick = (data: Ichar) => {
		setDeleteData(data);
		setDeleteModal(true);
	};

	const deleteCharacter = () => {
		if (!deleteData) return;
		fetchNui('deleteCharacter', deleteData);
	};

	const previewCharacter = (data: Ichar) => {
		fetchNui('previewCharacter', data);
	};

	const selectCharacter = (data: Ichar) => {
		fetchNui('selectCharacter', data);
	};

	const createNewCharacter = () => {
		if (!canCreateNew) return;
		if (!inputFirstname || !inputLastname || !inputDOB || !inputGender) return;
		fetchNui('createNewCharacter', {
			inputFirstname,
			inputLastname,
			inputDOB,
			inputGender,
		});
	};

	const selectSpawn = (spawn: any) => {
		fetchNui('selectSpawn', spawn);
	};

	return (
		<div className='nui-wrapper'>
			{deleteModal && (
				<div className='delete-modal'>
					<div className='delete-modal-inner'>
						<h1>Are you sure you want to remove {deleteData?.name}</h1>
						<div className='delete-modal-buttons'>
							<button onClick={(event) => setDeleteModal(false)}>
								Go back
							</button>
							<button onClick={(event) => deleteCharacter()}>Delete Now</button>
						</div>
					</div>
				</div>
			)}

			{newCharModal && (
				<div className='delete-modal'>
					<div className='delete-modal-inner'>
						<form className='form'>
							<div className='form-item'>
								<label htmlFor='firstname'>First Name</label>
								<input
									type='text'
									name='firstname'
									id='firstname'
									value={inputFirstname}
									onChange={(event) => setInputFirstnamne(event.target.value)}
								/>
							</div>
							<div className='form-item'>
								<label htmlFor='lastname'>Last Name</label>
								<input
									type='text'
									name='lastname'
									id='lastname'
									value={inputLastname}
									onChange={(event) => setInputLastnamne(event.target.value)}
								/>
							</div>
							<div className='form-item'>
								<label htmlFor='dob'>Date of Birth</label>
								<input
									type='text'
									name='dob'
									id='dob'
									value={inputDOB}
									onChange={(event) => setInputDOB(event.target.value)}
								/>
							</div>
							<div className='form-item'>
								<label htmlFor='gender'>Gender</label>
								<select
									name='gender'
									id='gender'
									onChange={(event) => setInputGender(event.target.value)}
								>
									<option value='Male'>Male</option>
									<option value='Female'>Female</option>
								</select>
							</div>
						</form>
						<div className='delete-modal-buttons'>
							<button onClick={(event) => setNewCharModal(false)}>
								Go back
							</button>
							<button onClick={(event) => createNewCharacter()}>
								Create Character
							</button>
						</div>
					</div>
				</div>
			)}

			{menu === 'scrollMenu' && (
				<div className='menu-wrapper'>
					<div className='menu'>
						<div className='menu-header'>
							<h1>{title}</h1>

							{description && <p>{description}</p>}
						</div>
						<div className='menu-content'>
							{data.map((item: any) => (
								<div key={item.id} className='menu-content-item'>
									<div className='menu-content-item-text'>
										<p>{item.label}</p>
									</div>
									<div className='menu-content-item-controls'>
										<div className='arrow-icon'>
											<IoCaretBack
												onClick={(event) =>
													handleArrowClick('decrease', item.id)
												}
											/>
										</div>
										<p>
											{item.value} / {item.values.length}
										</p>
										<div className='arrow-icon'>
											<IoCaretForward
												onClick={(event) =>
													handleArrowClick('increase', item.id)
												}
											/>
										</div>
									</div>
								</div>
							))}
						</div>
						<div className='menu-sidebar'>
							<div className='menu-sidebar-inner'>
								<div
									className='sidebar-icon'
									onClick={(event) => fetchNui('cameraClicked', 'head')}
								>
									<IoGlasses />
								</div>
								<div
									className='sidebar-icon'
									onClick={(event) => fetchNui('cameraClicked', 'body')}
								>
									<IoBody />
								</div>
								<div
									className='sidebar-icon'
									onClick={(event) => fetchNui('cameraClicked', 'feet')}
								>
									<IoFootsteps />
								</div>
							</div>
						</div>
						<div className='menu-footer'>
							<button onClick={(event) => fetchNui('continueClicked')}>
								Continue
							</button>
						</div>
					</div>
				</div>
			)}

			{menu === 'charMenu' && (
				<div className='menu-wrapper'>
					<div className='menu'>
						<div className='menu-header'>
							<h1>Select Character</h1>
						</div>
						<div className='menu-content'>
							{characters.map((character: any) => (
								<div className='char-item'>
									<div className='char-item-text'>
										<h1>{character.name}</h1>
										<p>{character.cid}</p>
									</div>
									<div className='char-item-icons'>
										<div
											className='char-item-icon'
											onClick={(event) => handleDeleteClick(character)}
										>
											<IoTrash />
										</div>
										<div
											className='char-item-icon'
											onClick={(event) => previewCharacter(character)}
										>
											<IoBody />
										</div>
										<div
											className='char-item-icon'
											onClick={(event) => selectCharacter(character)}
										>
											<IoCaretForward />
										</div>
									</div>
								</div>
							))}
							{canCreateNew && (
								<div className='char-item'>
									<div className='char-item-text'>
										<h1>Create new Character</h1>
									</div>
									<div className='char-item-icons'>
										<div
											className='char-item-icon'
											onClick={(event) => setNewCharModal(true)}
										>
											<IoAddCircle />
										</div>
									</div>
								</div>
							)}
						</div>
					</div>
				</div>
			)}

			{menu === 'spawnMenu' && (
				<div className='menu-wrapper'>
					<div className='menu'>
						<div className='menu-header'>
							<h1>{title}</h1>
						</div>
						<div className='menu-content'>
							{spawnData.map((spawn: any) => (
								<div className='char-item'>
									<div className='char-item-text'>
										<h1>{spawn.label}</h1>
									</div>
									<div className='char-item-icons'>
										<div
											className='char-item-icon'
											onClick={(event) => selectSpawn(spawn.coords)}
										>
											<IoCaretForward />
										</div>
									</div>
								</div>
							))}
						</div>
					</div>
				</div>
			)}
		</div>
	);
};

export default App;
